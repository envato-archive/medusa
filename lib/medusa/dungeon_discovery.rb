module Medusa
  class DungeonDiscovery
    def self.claim!(keeper)
      d = Dungeon.new
      d.claim!(keeper)
    end
  end
end