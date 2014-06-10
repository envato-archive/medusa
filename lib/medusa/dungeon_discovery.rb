require 'drb'

module Medusa

  def self.dungeon_discovery
    @dungeon_discovery ||= DungeonDiscovery.new
  end

  class DungeonDiscovery

    def initialize
      @labyrinths = []
      @logger = Medusa.logger.tagged(self.class.name)
    end

    def add_labyrinth(address)
      @labyrinths << ["druby://#{address}", nil]
    end

    def claim!(keeper)
      start_discovery

      @labyrinths.each do |(labyrinth, object)|
        @logger.debug("Checking labyrinth #{labyrinth}")
        if dungeon = object.claim_dungeon(keeper)
          @logger.debug("Dungeon claimed")
          return dungeon
        end
      end

      @logger.debug("No dungeons returned from the labyrinths.")

      return nil
    end

    private

    def start_discovery
      if @started_discovery.nil?
        
        # Start the receiver service.
        DRb.start_service

        @started_discovery = true

        @labyrinths.each do |labyrinth_array|
          @logger.debug("Connecting to labyrinth #{labyrinth_array[0]}")
          labyrinth_array[1] = DRbObject.new(nil, labyrinth_array[0])
        end

        @logger.debug("Labyrinths connected")
      end
    end
  end
end