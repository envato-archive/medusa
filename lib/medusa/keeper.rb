require_relative 'minion'
require_relative 'dungeon'
require_relative 'dungeon_discovery'

module Medusa

  # A Keeper is responsible for the management of it's Minions and Dungeons.
  # The Keeper receives commands from the Overlord and reports back any
  # results from the Minions.
  class Keeper
    attr_reader :name, :minions, :overlord, :plan

    def initialize
      @logger = Medusa.logger.tagged(self.class.name)
      @name = "Neverborn"
      @minions = []
    end

    # Instructs a keeper to serve the provided overlord.
    def serve!(overlord, name, plan)
      @overlord = overlord
      @name = name
      @plan = plan
      @logger = Medusa.logger.tagged("#{self.class.name} - #{name}")

      @logger.debug("I serve you my Overlord!")
    end

    # Makes the keeper claim a dungeon, and fit it out.
    def claim!(dungeon)
      @dungeon = dungeon
      @minions_union = @dungeon.fit_out!
    end

    # Abandon a dungeon, making it available for other
    # keepers to move in.
    def abandon_dungeon!
      @logger.debug("Abandoning dungeon")

      @dungeon.abandon!
      @dungeon = nil
      @ambassador = nil
    end

    # Work on a file. Returns true if file was allocated to a minion,
    # otherwise returns false.
    def work!(file)
      raise ArgumentError, "You must claim a dungeon first" if @minions_union.nil?
      result = @minions_union.delegate(:work!, file)
      @logger.debug("Got work request for #{file} = #{result}")
      result
    end

    # Reports information back to the overlord. Generally this is called
    # from by the minion's union upon receiving information from the minion.
    def report(information)
      @logger.debug("Report - #{information}")
      @overlord.receive_report(information)
    end

    def can_accept_more_work?
      @minions_union.can_work?
    end

    def working?
      @minions_union.working?
    end
  end
end
