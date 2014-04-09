module Medusa #:nodoc:
  # Medusa class responsible to dispatching runners and communicating with the master.
  #
  # The Worker is never run directly by a user. Workers are created by a
  # Master to delegate to Runners.
  #
  # The general convention is to have one Worker per machine on a distributed
  # network.
  class Worker
    traceable('WORKER')

    attr_reader :runners, :verbose, :runner_log_file, :io, :worker_id

    # Create a new worker.
    # * io: The IO object to use to communicate with the master
    # * num_runners: The number of runners to launch
    def initialize(opts = {})
      redirect_output("medusa-worker.log")

      trace "Starting worker"

      @worker_id = opts.fetch(:worker_id) { raise "Worker ID required" }
      @verbose = opts.fetch(:verbose) { false }
      @io = opts.fetch(:io) { raise "No IO Object" }
      @runners = []

      $0 = "[medusa] Worker"

      @messages = MessageStreamMultiplexer.new

      @messages.on_message do |message, stream|
        handle_message(message, stream)
      end

      @messages.on_stream_lost do |stream, remaining|
        if stream == @io
          terminate!
        elsif remaining == 1 # only the master remains
          trace "Stopping - only master remains"
          @io.send_message Messages::Died.new
          @messages.stop!
        end
      end

      # Let master know we've started up (and establish connection).
      @io.send_message(Messages::Ping.new)

      @messages << @io

      begin
        if File.exist?("medusa_worker_init.rb")
          eval(IO.read("medusa_worker_init.rb"))
        end

        boot_runners(opts.fetch(:runners) { 1 })

        @io.send_message(Messages::WorkerBegin.new)
      rescue => ex
        @io.send_message(Messages::WorkerStartupFailure.new(log: "#{ex.message}\n#{ex.backtrace.join('\n')}"))
        return
      end

      run!
    end

    def send_message_to_master(message)
      @io.send_message(message)
    end

    def allocate_free_runner
      runner = idle_runner
      runner.free = false
      runner
    end

    def remove_runner(runner)
      @runners.delete(runner)
    end

    def check_runners_ready
      if @runners.length == 0
        @io.send_message(Messages::WorkerStartupFailure.new(log: "All runners failed to start"))
      end    
    end

    def shutdown_idle_runners
      @runners.select(&:free?).each do |r|
        begin
          r.send_message(Messages::Shutdown.new)
        rescue IOError 
          # May have already shut down.          
        end
      end
    end

    def terminate!
      @running = false
      @runners.each do |r|
        begin
          r.send_message(Messages::Shutdown.new)
        rescue IOError 
          # May have already shut down.          
        end
      end
    end

    private

    def boot_runners(num_runners) #:nodoc:
      trace "Booting #{num_runners} Runners"
      runner_base_id = 0
      num_runners.times do |runner_id|

        runner = begin
          r = RunnerClient.new(runner_base_id + runner_id)
          r.boot!
          r
        rescue Errno::EADDRINUSE
          runner_base_id += 1
          retry
        end

        @messages << runner.message_stream
        @runners << runner
      end
      send_message_to_master(Messages::InitializerMessage.new(output: "#{num_runners} runners started"))
      trace "#{@runners.size} Runners booted"
    rescue => ex
      trace ex.class.name
      trace ex.message
      trace ex.backtrace
    end

    # Continuously process messages
    def run! #:nodoc:
      trace "Processing Messages"

      @running = true

      Thread.abort_on_exception = true

      @messages.run!

      trace "Done processing messages"
    end

    def handle_message(message, from)
      if message.respond_to?(:handle_by_worker)
        if from == @io
          message.handle_by_worker(self)
        else
          runner = @runners.detect { |r| r.message_stream == from }
          message.handle_by_worker(self, runner)
        end
      end
    end

    # Get the next idle runner
    def idle_runner #:nodoc:
      idle_r = nil
      while idle_r.nil?
        idle_r = @runners.detect(&:free?)
      end
      return idle_r
    end
  end
end
