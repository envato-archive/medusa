require_relative 'minion'
require_relative 'dungeon'
require_relative 'dungeon_discovery'
require_relative 'keeper_ambassador'

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

    def serve!(overlord, name, plan)
      @overlord = overlord
      @name = name
      @plan = plan
      @logger = Medusa.logger.tagged("#{self.class.name} - #{name}")

      @logger.debug("I serve you my Overlord!")
    end

    def claim!(dungeon)
      @dungeon = dungeon
      @minions_union = @dungeon.fit_out!
    end

    def abandon_dungeon!
      @logger.debug("Abandoning dungeon")

      @dungeon.abandon!
      @dungeon = nil
      @ambassador = nil
    end

    def work!(file)
      raise ArgumentError, "You must claim a dungeon first" if @minions_union.nil?
      result = @minions_union.delegate(:work!, file)
      @logger.debug("Got work request for #{file} = #{result}")
      result
    end

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

    def inform_work_result(result)
      @overlord.inform_work_result(result)
    end

    def inform_work_complete(file)
      @overlord.inform_work_complete(file)
    end

  end
end
