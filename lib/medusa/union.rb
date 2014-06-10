require 'drb'

require_relative 'union_approved_workspace'
require_relative 'ruby_fixes'

module Medusa
  # Minions have been abused by their Keepers for Aeons. Recently, they got together
  # and created a Union, which has prevented the Keepers from overloading them
  # with work.
  #
  # Being the Minion's representatives in the Dungeon, the Union does the job
  # of rejecting work if no minion is free, and providing a safe area for the
  # minions to report back their work progress.
  class Union
    include DRbUndumped

    class ReportCollector
      include DRbUndumped

      def initialize
        @reports = Queue.new
      end

      def report(information)
        @reports << information
      end

      def pop
        @reports.pop
      end
    end

    def initialize(reporter, port = 10000)
      @workers ||= []
      @reporter = reporter
      @internal_reporter = ReportCollector.new
      @port = port
      @logger = Medusa.logger.tagged(self.class.name)

      @reporting_server = DRb::DRbServer.new("druby://localhost:#{port}", @internal_reporter)

      @available_workers = Queue.new

      # The reporting thread collects reports received on the server
      # the broadcasts them to the reporters in a single-threaded
      # manner.
      @reporting_thread = Thread.new do
        begin
          loop do
            information = @internal_reporter.pop
            @reporter.report(information)
          end
        rescue => ex
          puts ex
        end
      end
    end

    # Accepts a minion into the union, adding them to the
    # pool of workers.
    def represent(worker)
      @port += 1

      workspace = UnionApprovedWorkspace.new(@port)
      workspace.embrace(worker, @reporting_server.uri)
      @workers << workspace
    end

    # Verifies the connection to all the minions. Blocks
    # until we're established they're all verified.
    def wait_for_ready
      @logger.debug("Waiting for workers to be ready")
      @workers.each(&:verify)
      @logger.debug("Workers are ready")
    end

    # Returns true if #delegate is going to find a free minion.
    def can_work?
      @available_workers.length > 0
    end

    # Returns true if any minions are currently working.
    def working?
      @available_workers.length < @workers.length
    end

    # Locates a free minion and makes them run the given activity.
    # The activity must match a method name on the minion, with the
    # payload being the method's arguments. Returns true if there
    # was a free minion, otherwise returns false.
    def delegate(activity, *payload)
      @logger.debug("Checking for free workers from #{@available_workers.length} available worker(s)...")

      worker = @available_workers.pop(true) unless @available_workers.empty?
      return false if worker.nil?

      @logger.debug("We have a worker free.")

      Thread.new do
        begin
          @logger.debug("Delegating #{activity} to worker")
          worker.send(activity, *payload)
        rescue => ex
          @logger.error("ERROR - #{ex.to_s}")
        ensure
          @available_workers.push(worker)
          @logger.debug("Worker has finished their job")
        end
      end

      return true
    end

    # Provides training to all the minions at once. As soon
    # as a minion has been trained, it's placed onto the
    # available workers pool.
    def provide_training(training_plan)
      @workers.each do |workspace|
        Thread.new do
          workspace.train!(training_plan)
          @available_workers.push(workspace)
        end
      end
    end

    # Blocks the current thread until all minions have completed their
    # work.
    def wait_for_complete
      @logger.debug("Waiting for workers to complete their work - #{@available_workers.length}")
      count = 0
      while count < @workers.length
        @available_workers.pop
        count += 1
        @logger.debug("#{count} Worker(s) done, out of #{@workers.length}")
      end

      # Put the workers back into the available workers pool
      @workers.each { |w| @available_workers.push(w) }

      @logger.debug("All workers done.")
    end

    # Blocks the current thread until there is a free minion.
    def wait_for_free
      worker = @available_workers.pop
      @available_workers.push(worker)
    end

    # Blocks the current thread until all minions have completed their
    # work, and then releases the minions, and terminates the reporting
    # server.
    def finished
      wait_for_complete
      @workers.each(&:release)

      # Give time for reporting to finish. FIXME - This is a hack.
      sleep(2)

      @reporting_thread.kill
      @reporting_server.stop_service
    end
  end
end
