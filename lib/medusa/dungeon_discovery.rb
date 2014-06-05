require 'drb'

module Medusa

  def self.dungeon_discovery
    @dungeon_discovery ||= DungeonDiscovery.new
  end

  class DungeonDiscovery

    def initialize
      @labrynths = []
      @logger = Medusa.logger.tagged(self.class.name)
    end

    def add_labrynth(address)
      @labrynths << ["druby://#{address}", nil]
    end

    def claim!(keeper)
      start_discovery

      @labrynths.each do |(labrynth, object)|
        @logger.debug("Checking labrynth #{labrynth}")
        if dungeon = object.claim_dungeon(keeper)
          return dungeon
        end
      end

      @logger.debug("No dungeons returned from the labrynths.")

      return nil
    end

    private

    def start_discovery
      if @started_discovery.nil?
        
        # Start the receiver service.
        DRb.start_service

        @started_discovery = true

        @labrynths.each do |labrynth_array|
          @logger.debug("Connecting to labrynth #{labrynth_array[0]}")
          labrynth_array[1] = DRbObject.new(nil, labrynth_array[0])
        end

        @logger.debug("Labrynths connected")
      end
    end
  end
end