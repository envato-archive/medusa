module Medusa

  # The keeper's ambassador is their representative in charge of the
  # daily running of their dungeon, keeping track of who is doing
  # what work, and who is free for more work.
  #
  # We require the Ambassador because Minions are remote agents and
  # we don't want the Keeper to continually poll for a free minion
  # over the network.
  class KeeperAmbassador
    include DRbUndumped

    def initialize(keeper, minions)
      @logger = Medusa.logger.tagged(self.class.name)
      @logger.debug("minions: #{minions.inspect}")
      @minions = minions.flatten
      @keeper = keeper
      @free_minions = @minions.dup
      @mutex = Mutex.new
    end

    def delegate_work!(file)
      minion = @mutex.synchronize do
        @free_minions.pop
      end

      if minion
        @logger.debug("Delegating to #{minion}!")
        minion.work!(file, self)

        return true
      else
        return false
      end
    end

    def minions_free?
      @free_minions.length > 0
    end

    def work_remains?
      @free_minions.length != @minions.length
    end

    def inform_work_complete(file, minion)
      # @logger.debug("Got complete. #{minion_name} #{@minions.first.class.name}")
      minion = @mutex.synchronize do
        @free_minions.unshift(minion)
      end
      # @free_minions.unshift(@minions.select{ |m| m.name == minion_name })
      @logger.debug("Got complete. There are #{@free_minions.length} free.")
      @keeper.inform_work_complete(file)
    end

    def inform_work_result(result)
      @logger.debug("Got result - #{result.name}")
      @keeper.inform_work_result(result)
      @logger.debug("RESULT SENT")
    end

  end
end