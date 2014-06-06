require 'securerandom'
require 'pathname'

require_relative 'dungeon_constructor'
require_relative 'logger'
require_relative 'minion'

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
  # can be part of a persistent Labrynth for internal network dungeon discovery.
  class Dungeon
    include DRbUndumped
    ALPHABET = ('a'..'z').to_a

    attr_reader :location, :minions, :name

    def initialize(minions = 3)
      @name = @original_name = "#{DUNGEON_NAMES.sample} #{SecureRandom.random_number(666)}"
      @logger = Medusa.logger.tagged("#{self.class.name} #{@name}")

      @minions = 1.upto(minions).collect { |number| Minion.new(self, number) }

      safe_name = @name.scan(/[\w\d]+/).join("-").gsub(/-{2,}/, '-')
      @location = Pathname.new("/tmp/medusa/dungeons/#{safe_name}")
    end

    # A keeper will claim the dungeon and spawn
    # minions as many minions as it can handle.
    def claim!(keeper, plan)
      @keeper ||= keeper

      raise ArgumentError, "Already claimed" if keeper != @keeper

      @name = "#{keeper.name}'s #{@original_name}"

      @logger.debug("Claimed by a keeper! Henceforth I will be known as #{@name}.")
      @logger = Medusa.logger.tagged("#{self.class.name} #{@name}")
    end

    def fit_out(plan)
      DungeonConstructor.build!(self, plan)

      spawn_minions
      @minions
    end

    def claimed?
      !!@keeper
    end

    def abandon!
      @minions.each(&:die!)
      @name = @original_name
      @keeper = nil
      @logger.debug("Abandoned by my keeper! Resuming my diminished life as #{@name}.")
    end

    private

    def prepare(plan)
      @logger.debug("Preparing dungeon...")
    end

    def spawn_minions
      @logger.debug("Spawning #{@minions.length} minions...")

      @minions.each do |minion|
        minion.receive_the_gift_of_life!(@keeper)
      end      
    end
  end
end