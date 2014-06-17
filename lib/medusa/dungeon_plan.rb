module Medusa

  # Keepers can manage a Dungeon, but it's up to the Overlord to
  # tell the Keepers what that Dungeon looks like. This is the
  # Overlord's plan.
  class DungeonPlan

    # The blueprints are a list of things which must be done in sequence
    # to setup the dungeon to make it suitable for minion habitation.
    # For example, pulling down code, bundle installing, etc.
    attr_reader :blueprints

    # Represents things a minion needs to do before it can start work.
    # For example, creating a database, etc.
    attr_reader :minion_training

    def initialize
      @blueprints = [Initializers::DumbSync.new, Initializers::BundleCache.new]
      @minion_training = []
    end

  end
end
