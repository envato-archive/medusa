require_relative 'minion'
require_relative 'dungeon'
require_relative 'dungeon_discovery'

module Medusa

  # A Keeper is responsible for the management of it's Minions and Dungeons.
  # The Keeper receives commands from the Overlord and reports back any 
  # results from the Minions.
  class Keeper
    attr_reader :name, :minions

    def initialize
      @logger = Medusa.logger.tagged(self.class.name)
      @name = "Neverborn"
    end

    def serve!(overlord, name)
      @overlord = overlord
      @name = name
      @logger = Medusa.logger.tagged("#{self.class.name} - #{name}")

      @logger.debug("I serve you my Overlord!")

      if @dungeon = Medusa.dungeon_discovery.claim!(self)
        @minions = @dungeon.fit_out(nil)
      end

      raise ArgumentError, "No available dungeons" if @dungeon.nil?
    end

    def abandon_dungeon!
      @logger.debug("Abandoning dungeon")

      @dungeon.abandon!
    end

    def work!(file)
      raise ArgumentError, "No minions" if @minions.nil? || @minions.length == 0
      @minions.select(&:free?).first.work!(file)
    end

    def free?
      @minions && @minions.select(&:free?).length > 0
    end

    def working?
      @minions && @minions.select(&:free?).length != @minions.length
    end

    def receive_result(file, result, minion)
      @logger.debug("Received result for file #{file}")
      @logger.debug("#{@minions.select(&:free?).length} minions are free.")

      @overlord.receive_result(file, result)
    rescue => ex
      @logger.error(ex.to_s)
    end

    def fatal_error(file, exception, minion)
      @logger.debug("Received a fatal error from a minion on #{file}")
      @logger.debug(exception.to_s)
    end

    private

    def claim_dungeon!
      @logger.debug("Locating a dungeon...")

      @dungeon = Dungeon.new
      @minions = @dungeon.claimed!(self, nil)
    end   

    def handle_command(message)
      @logger.debug("Received command #{message}")
    end

    def handle_message(message)
      @logger.debug("Received message #{message}")      
    end
  end
end
