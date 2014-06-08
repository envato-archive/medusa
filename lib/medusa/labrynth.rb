require 'drb'

require_relative 'dungeon'

module Medusa

  # A Labrynth provides access to Dungeons over a TCP connection.
  class Labrynth
    attr_reader :dungeons

    def initialize(bind_address)
      @dungeons = []
      @bind_address = bind_address
      @mutex = Mutex.new

      @logger = Medusa.logger.tagged(self.class.name)
    end

    def serve!
      raise ArgumentError, "No dungeons configured" if @dungeons.length == 0

      @logger.info("Starting labrynth at #{@bind_address}")

      @dungeons = @dungeons.freeze

      @server = DRb::DRbServer.new("druby://#{@bind_address}", self)
      @server.thread.join
    end

    def claim_dungeon(keeper)
      @mutex.synchronize do
        free_dungeon = @dungeons.reject(&:claimed?).sample
        if free_dungeon
          free_dungeon.claim!(keeper, keeper.plan)
          return free_dungeon
        else
          return nil
        end
      end
    end
  end
end
