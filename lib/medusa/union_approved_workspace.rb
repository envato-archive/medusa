require 'drb'

module Medusa

  # The new Union Approved Workspace program was recently introduced by the
  # minion's Union to provide them a safe execution environment for their
  # work.
  #
  # Technically speaking, this workspace forks the process, and establishes
  # DRb communication between the parent and child processes. One for the
  # minion's commands, and one for reporting back to the Union their results.
  class UnionApprovedWorkspace
    def initialize(port)
      @port = port
      @logger = Medusa.logger.tagged(self.class.name)
    end

    def embrace(target, reporting_uri)
      @target = target

      @pid = fork do
        reporting_client = DRbObject.new(nil, reporting_uri)
        target.report_to(reporting_client)

        server = DRb::DRbServer.new("druby://localhost:#{@port}", target)
        server.thread.join
      end

      trap("KILL") { Process.kill("KILL", @pid) }
    end

    # Verifies the connection is alive.
    def verify
      tries = 0

      begin
        @logger.debug("Checking connection to #{@port}...")
        object = DRbObject.new(nil, "druby://localhost:#{@port}")
        object.to_s
        true
      rescue Errno::ECONNREFUSED, DRb::DRbConnError
        @logger.debug("Retrying connection to #{@port}...")
        raise "Couldn't establish workspace connection to #{@port}" if tries > 10

        tries += 1
        sleep(0.1)
        retry
      end
    end

    def release
      Process.kill("KILL", @pid) if @pid
      @pid = nil
      @target = nil
      @reporter = nil
    end

    def method_missing(name, *args)
      client = DRbObject.new(nil, "druby://localhost:#{@port}")
      last_error = nil

      work_thread = Thread.new do
        begin
          client.send(name, *args)
        rescue => ex
          last_error = ex
        end
      end

      work_thread.join
      raise last_error if last_error
    end
  end
end
