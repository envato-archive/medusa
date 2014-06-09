require 'drb'

require_relative 'dungeon'

module Medusa

  # A Labrynth provides access to Dungeons over a TCP connection.
  class Labrynth
    attr_reader :dungeons

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

      @logger.info("Starting labrynth at #{@bind_address} with #{@dungeons.length} dungeon(s).")

      $0 = "[medusa] Labrynth serving at #{@bind_address} with #{@dungeons.length} dungeon(s)."

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
