
Thread.abort_on_exception=true

module Medusa

  # Manages issues commands to multiple keepers at once. This should be
  # the only part the the communication pipeline which needs to
  # worry about threads.
  class KeeperPool
    def initialize(names)
      @keepers = []

      @names = names.dup
      @logger = Medusa.logger.tagged(self.class.name)
    end

    def add_keeper(keeper)
      @keepers << keeper
    end

    # Instructs all keepers to prepare their dungeon,
    # and train their minions. All dungeons are
    # prepared in parellel, and this method will
    # block until all dungeons are ready.
    def prepare!(overlord)
      threads = []

      plan = overlord.plan

      @main_thread_proxy = MethodProxy.new(overlord)
      @logger.debug("Preparing #{@keepers.length} Keepers")

      keeper_dungeon_pairs = []

      @keepers.each do |keeper|
        name = @names.sample
        @names.delete(name)

        keeper.serve!(@main_thread_proxy, name, plan)
        dungeon = Medusa.dungeon_discovery.claim!(keeper)

        if dungeon
          keeper_dungeon_pairs << [keeper, dungeon]
          @logger.debug("Keeper #{keeper.name} will claim dungeon #{dungeon.name}")
        end
      end

      keeper_dungeon_pairs.each do |(keeper, dungeon)|
        threads << Thread.new do
          begin
            keeper.claim!(dungeon)
          rescue => ex
            @logger.debug("Dungeon claim error: #{ex.to_s} #{ex.backtrace}")
          end
        end
      end

      while threads.any?(&:alive?)
        @main_thread_proxy.process!
        sleep(0.01)
      end

      threads.each(&:join)
    end

    # Continually dishes out work to keepers until all work is gone.
    # Blocks until all work is done.
    def accept_work!(work)
      while file = work.shift
        @logger.debug("Finding a keeper for #{file}")

        process!

        until @keepers.any? { |keeper| keeper.work!(file) }
          process!
        end
      end

      @logger.debug("Impatiently waiting for underlings to finish")

      # Wait for the keepers to finish the work.
      while @keepers.any?(&:working?)
        process!
      end

      # Process the last messages after the keepers have finished.
      process!

      @keepers.each do |keeper|
        keeper.abandon_dungeon!
      end

      # Capture any abandonment issues.
      process!
    end

    private

    def process!
      @main_thread_proxy.process!
    end

    # The method proxy allows the Keepers to report back information
    # to the Overlord's thread so that the Overlord doesn't need
    # worry about thread safety.
    #
    # Messages from the various keeper threads are put into a queue
    # and then processed later by #process!
    class MethodProxy
      def initialize(overlord)
        @queue = []
        @mutex = Mutex.new
        @overlord = overlord
        @logger = Medusa.logger.tagged(self.class.name)
      end

      def method_missing(name, *args)
        @mutex.synchronize do
          @queue << [name, args]
        end
      end

      def process!
        @mutex.synchronize do
          while !@queue.empty?
            command = @queue.pop
            @overlord.send(command[0], *command[1])
          end
        end
      end
    end

  end
end
