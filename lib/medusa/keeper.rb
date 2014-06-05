require_relative 'minion'
require_relative 'dungeon'
require_relative 'dungeon_discovery'
require_relative 'keeper_ambassador'

module Medusa

  # A Keeper is responsible for the management of it's Minions and Dungeons.
  # The Keeper receives commands from the Overlord and reports back any 
  # results from the Minions.
  class Keeper
    attr_reader :name, :minions, :overlord

    def initialize
      @logger = Medusa.logger.tagged(self.class.name)
      @name = "Neverborn"
      @minions = []
    end

    def serve!(overlord, name)
      @overlord = overlord
      @name = name
      @logger = Medusa.logger.tagged("#{self.class.name} - #{name}")

      @logger.debug("I serve you my Overlord!")
    end

    def claim!(dungeon)
      @dungeon = dungeon
      
      minions = @dungeon.fit_out(nil)

      @ambassador = KeeperAmbassador.new(self, minions)
    end

    def abandon_dungeon!
      @logger.debug("Abandoning dungeon")

      @dungeon.abandon!
      @dungeon = nil
      @ambassador = nil
    end

    def work!(file)
      return @ambassador.delegate_work!(file)
    end

    def can_accept_more_work?
      @ambassador.minions_free?
    end

    def working?
      @ambassador.work_remains?
    end

    def inform_work_result(result)
      @overlord.inform_work_result(result)
    end

    def inform_work_complete(file)
      @overlord.inform_work_complete(file)
    end

  end
end
