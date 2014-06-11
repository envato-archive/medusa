require 'securerandom'
require 'pathname'

require_relative 'dungeon_constructor'
require_relative 'logger'
require_relative 'minion'
require_relative 'union'

module Medusa

  DUNGEON_NAMES = [
    "Fields of Asphodel",
    "Elysium",
    "Isles of the Damned",
    "Styx",
    "Acheron",
    "Lethe",
    "Phlegethon",
    "Cocytus",
    "Tartarus"
  ]

  # Oh how far can we stretch this analogy!
  #
  # The Dungeon is where we hold your code. Minions are responsible for doing
  # work in a Dungeon (testing), as decided by the Overlord.
  #
  # A Dungeon starts as unclaimed, meaning it's a place where code can be run
  # but needs to be claimed by a Keeper to be of service.
  #
  # Dungeons can be created on-demand when Medusa is running locally, or they
  # can be part of a persistent Labyrinth for internal network dungeon discovery.
  class Dungeon
    include DRbUndumped
    ALPHABET = ('a'..'z').to_a

    attr_reader :location, :minions, :name, :keeper

    # Creates a new dungeon with the given number of minions. Note that
    # minion processes won't be started until the dungeon has been claimed
    # and then fitted out. Use the #port_start option to control which
    # port range to use for internal minion communications. You'll want
    # to use it when running multiple dungeons within a Labyrinth.
    def initialize(minions = 3)
      @name = @original_name = "#{DUNGEON_NAMES.sample} #{SecureRandom.random_number(666)}"
      @logger = Medusa.logger.tagged("#{self.class.name} #{@name}")

      @number_of_minions = minions

      safe_name = @name.scan(/[\w\d]+/).join("-").gsub(/-{2,}/, '-')
      @location = Pathname.new("/tmp/medusa/dungeons/#{safe_name}")
    end

    # A keeper will claim the dungeon and spawn
    # minions as many minions as it can handle.
    def claim!(keeper, plan)
      @keeper ||= keeper

      raise ArgumentError, "Already claimed" if keeper != @keeper

      @dungeon_blueprints = plan.blueprints.dup
      @minion_training = plan.minion_training.dup

      @name = "#{keeper.name}'s #{@original_name}"

      @logger.debug("Claimed by a keeper! Henceforth I will be known as #{@name}.")
      @logger.debug("blueprints are #{@dungeon_blueprints.inspect}")
      @logger = Medusa.logger.tagged("#{self.class.name} #{@name}")
    end

    # Fits out the dungeon according to the plan provided in #claim!. This
    # includes building the dungeon using the DungeonBuilder, and spawning
    # minions for work, returning their local Union which can be used to
    # get the little critters working.
    def fit_out!
      raise ArgumentError, "Not claimed" if @keeper.nil?

      @logger.debug("Fitting out the Dungeon.")
      build_dungeon
      spawn_minions

      return @union
    end

    def claimed?
      !!@keeper
    end

    # Abandon the dungeon, dismantling the union and killing the poor minions.
    def abandon!
      @union.finished
      @name = @original_name
      @keeper = nil
      @logger.debug("Abandoned by my keeper! Resuming my diminished life as #{@name}.")
    end

    # Reports information to the keeper from the union.
    def report(information)
      @keeper.report(information)
    end

    private

    def build_dungeon
      @logger.debug("Preparing dungeon... #{@dungeon_blueprints.inspect}")
      DungeonConstructor.build!(self, @dungeon_blueprints)
    end

    def spawn_minions
      @logger.debug("Spawning #{@number_of_minions} minions...")

      @union = Union.new(self)

      @number_of_minions.times do |minion_name|
        minion = Minion.new(self, minion_name)
        @union.represent(minion)
      end

      @union.wait_for_ready
      @union.provide_training(@minion_training)
    end
  end
end
