module Medusa #:nodoc:
  # Medusa class responsible to dispatching runners and communicating with the master.
  #
  # The Worker is never run directly by a user. Workers are created by a
  # Master to delegate to Runners.
  #
  # The general convention is to have one Worker per machine on a distributed
  # network.
  class Worker
    include Medusa::Messages::Worker
    traceable('WORKER')

    attr_reader :runners, :verbose, :runner_log_file

    def self.setup(&block)
      @setup ||= []
      @setup << block
    end

    def self.setups
      @setup || []
    end

    # Create a new worker.
    # * io: The IO object to use to communicate with the master
    # * num_runners: The number of runners to launch
    def initialize(opts = {})
      redirect_output("medusa-worker.log")

      trace "Starting worker"

      @verbose = opts.fetch(:verbose) { false }
      @io = opts.fetch(:io) { raise "No IO Object" }
      @runners = []
      @listeners = []
      @options = opts.fetch(:options) { "" }

      $0 = "[medusa] Worker"

      @messages = MessageStreamMultiplexer.new

      @messages.on_message do |message, stream|
        handle_message(message, stream)
      end

      @messages << @io

      begin
        Worker.setups.each { |proc| proc.call }

        @runner_event_listeners = Array(opts.fetch(:runner_listeners) { nil })
        @runner_event_listeners.select{|l| l.is_a? String}.each do |l|
          @runner_event_listeners.delete_at(@runner_event_listeners.index(l))
          listener = eval(l)
          @runner_event_listeners << listener if listener.is_a?(Medusa::RunnerListener::Abstract)
        end
        @runner_log_file = opts.fetch(:runner_log_file) { nil }

        boot_runners(opts.fetch(:runners) { 1 })

        trace "Firing worker begin"
        @io.send_message(Medusa::Messages::Worker::WorkerBegin.new)
      rescue => ex
        @io.send_message(Medusa::Messages::Worker::WorkerStartupFailure.new(log: "#{ex.message}\n#{ex.backtrace.join('\n')}"))
        return
      end

      run!
    end

    # message handling methods

    # When a runner wants a file, it hits this method with a message.
    # Then the worker bubbles the file request up to the master.
    def request_file(message, runner)
      @io.send_message(RequestFile.new)
      runner[:idle] = true
    end

    def example_group_started(message, runner)
      @io.send_message(ExampleGroupStarted.new(eval(message.serialize)))
    end

    def example_group_finished(message, runner)
      @io.send_message(ExampleGroupFinished.new(eval(message.serialize)))
    end

    def example_started(message, runner)
      @io.send_message(ExampleStarted.new(eval(message.serialize)))
    end

    def example_group_summary(message, runner)
      @io.send_message(ExampleGroupSummary.new(eval(message.serialize)))
    end

    def file_complete(message, runner)
      runner[:idle] = true
      trace "INF #{message.file.inspect}"
      @io.send_message(FileComplete.new(file: message.file))
    end

    # When the master sends a file down to the worker, it hits this
    # method. Then the worker delegates the file down to a runner.
    def delegate_file(message)
      runner = idle_runner
      runner[:idle] = false
      runner[:io].send_message(RunFile.new(eval(message.serialize)))
    end

    # When a runner finishes, it sends the results up to the worker. Then the
    # worker sends the results up to the master.
    def relay_results(message, runner)
      trace "Relaying results to Master #{@io}: #{message.inspect}"
      @io.send_message(Results.new(eval(message.serialize)))
    end

    def runner_startup_failure(message, runner)
      @runners.delete(runner)

      @io.send_message(RunnerStartupFailure.new(log: message.log))

      if @runners.length == 0
        @io.send_message(WorkerStartupFailure.new(log: "All runners failed to start"))
      end
    end

    # When a master issues a shutdown order, it hits this method, which causes
    # the worker to send shutdown messages to its runners.
    def shutdown
      @running = false
      trace "Notifying #{@runners.size} Runners of Shutdown"
      @runners.each do |r|
        trace "Sending Shutdown to Runner"
        trace "\t#{r.inspect}"
        r[:io].send_message(Shutdown.new)
      end
      Thread.exit
    end

    private

    def boot_runners(num_runners) #:nodoc:
      trace "Booting #{num_runners} Runners"
      num_runners.times do |runner_id|

        transport = TcpTransport.new("localhost", 19100 + runner_id)
        port = transport.port
        trace "Worker communicating on port #{port}"
        # parent_transport, child_transport = PipeTransport.pair

        child = fork do
          # parent_transport.close
          # child_stream = MessageStream.new(child_transport)
          child_stream = MessageStream.new(TcpTransport.new("localhost", port))
          Medusa::Runner.new(:id => runner_id, :io => child_stream, :verbose => @verbose, :runner_log_file => @runner_log_file, :options => @options)
        end

        trace "Runner PID: #{child}"
        
        # child_transport.close
        # parent_stream = MessageStream.new(parent_transport)
        transport.server!
        parent_stream = MessageStream.new(transport)

        @messages << parent_stream

        @runners << { :id => runner_id, :pid => child, :io => parent_stream, :idle => false }
      end
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
      trace "Handle message #{message}"
      if from == @io && !message.class.to_s.index("Master").nil?
        message.handle(self)
      elsif !message.class.to_s.index("Runner").nil?
        runner = @runners.detect { |r| r[:io] == from }
        message.handle(self, runner)
      end
    end

    # Get the next idle runner
    def idle_runner #:nodoc:
      idle_r = nil
      while idle_r.nil?
        idle_r = @runners.detect{|runner| runner[:idle]}
      end
      return idle_r
    end
  end
end
