module Medusa

  # The keeper's ambassador is their representative in charge of the
  # daily running of their dungeon, keeping track of who is doing
  # what work, and who is free for more work.
  #
  # We require the Ambassador because Minions are remote agents and
  # we don't want the Keeper to continually poll for a free minion
  # over the network.
  class KeeperAmbassador

    def initialize(keeper, minions)
      @minions = minions
      @keeper = keeper
      @free_minions = @minions.dup
    end

    def delegate_work!(file)
      if minion = @free_minions.pop
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
      @free_minions.push(minion)
      @keeper.inform_work_complete(file)
    end

    def inform_work_result(result)
      @keeper.inform_work_result(result)
    end

  end
end