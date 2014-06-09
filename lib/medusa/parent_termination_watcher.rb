module Medusa
  class ParentTerminationWatcher
    def initialize
      @pid = Process.ppid
      @logger = Medusa.logger.tagged(self.class.name)
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
