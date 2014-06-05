
Thread.abort_on_exception=true

module Medusa
  # Manages issues commands to multiple keepers at once.
  class KeeperPool
    def initialize(names)
      @keepers = []

      @names = names.dup
      @logger = Medusa.logger.tagged(self.class.name)
    end

    def add_keeper(keeper)
      @keepers << keeper
    end

    def prepare!(overlord)
      threads = []

      @logger.debug("Preparing #{@keepers.length} Keepers")

      main_thread_proxy = MethodProxy.new(overlord)

      @keepers.each do |keeper|
        name = @names.sample
        @names.delete(name)

        threads << Thread.new do
          @logger.debug("Claiming a keeper")
          keeper.serve!(main_thread_proxy, name)
          @logger.debug("Keeper claimed!")
        end
      end

      while threads.any?(&:alive?)
        main_thread_proxy.process!
      end

      threads.each(&:join)
    end

    # The method proxy allows the Keepers to report back information
    # to the Overlord's thread so that the Overlord doesn't need 
    # worry about thread safety.
    class MethodProxy
      def initialize(overlord)
        @queue = Queue.new
        @overlord = overlord
      end

      def method_missing(name, *args)
        @queue << [name, args]
      end

      def process!
        while !@queue.empty?
          command = @queue.pop
          @overlord.send(command[0], *command[1])
        end
      end
    end

  end
end