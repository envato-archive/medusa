require_relative 'minion'

module Medusa

  # A Keeper is responsible for the management of Minions, communicating
  # commands from the Overlord and reporting results from Minions back to the
  # Overlord.
  class Keeper
    def initialize(message_handler)
      @message_handler = message_handler
      @minions = []

      @logger = Medusa.logger.tagged(self.class.name)
    end

    def create_dungeon!
      @logger.debug("Creating dungeon")
    end

    def spawn_minions!
      @logger.debug("Spawning minions")

      @minions << Minion.new(self)
      @minions << Minion.new(self)
    end

    def eradicate_minions!
      @logger.debug("Eradicating minions")
    end

    def work!
      @minions.each do |minion|
        minion.work!
      end
    end

    def handle_command(message)
      @logger.debug("Received command #{message}")
    end

    def handle_message(message)
      @logger.debug("Received message #{message}")      
    end
  end
end
