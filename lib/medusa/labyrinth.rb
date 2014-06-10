require 'drb'

require_relative 'dungeon'

module Medusa

  # A Labyrinth provides access to Dungeons over a TCP connection.
  class Labyrinth
    attr_reader :dungeons

    # Returns true if there's a labyrinth available at the
    # given location.
    def self.available_at?(address)
      obj = DRb::DRbObject.new(nil, "druby://#{address}")
      obj.to_s
      return true
    rescue Errno::ECONNREFUSED, DRb::DRbConnError
      return false
    rescue => ex
      puts "Unexpected error: #{ex.to_s}"
      puts ex.class.name
    end

    def initialize(bind_address)
      @dungeons = []
      @bind_address = bind_address
      @mutex = Mutex.new

      @logger = Medusa.logger.tagged(self.class.name)
    end

    def serve!
      raise ArgumentError, "No dungeons configured" if @dungeons.length == 0

      @logger.info("Starting labyrinth at #{@bind_address} with #{@dungeons.length} dungeon(s).")

      $0 = "[medusa] Labyrinth serving at #{@bind_address} with #{@dungeons.length} dungeon(s)."

      @dungeons = @dungeons.freeze

      @server = DRb::DRbServer.new("druby://#{@bind_address}", self)
      @server.thread.join
    end

    # Called by client connections, in order to claim a dungeon
    # for the given keeper. Returns nil if no dungeon is available.
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
