module Medusa

  # Observes the process ID of the parent process, blocking the current
  # thread until it changes.
  #
  # We use this to find out when a child forked process looses its parent, as
  # the child's parent ID changes to the init process when the original
  # parent process dies.
  class ParentTerminationWatcher
    class Terminated < StandardError; end
    
    def initialize
      @pid = Process.ppid
      @logger = Medusa.logger.tagged(self.class.name)
    end

    def self.termination_thread!
      Thread.abort_on_exception = true
      Thread.new do
        new.block_until_parent_dead!
        raise Terminated
      end
    end

    def block_until_parent_dead!
      watcher_thread = Thread.new do
        while @pid == Process.ppid
          sleep(0.1)
        end
      end

      watcher_thread.join
      @logger.debug("Parent process changed from #{@pid} to #{Process.ppid}")
    end
  end
end
