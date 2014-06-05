require 'spec_helper'

require_relative '../lib/medusa/dungeon'
require_relative '../lib/medusa/dungeon_plan'

describe Medusa::Dungeon do
  subject(:dungeon) { described_class.new }

  describe "#claim!" do
    let(:plan) { Medusa::DungeonPlan.new }
    let(:keeper) { Medusa::Keeper.new }

    it "constructs the Dungeon" do
      expect(Medusa::DungeonConstructor).to receive(:build!).with(dungeon, plan)

      dungeon.claim!(keeper, plan)
    end

    it "spawns minions" do
      allow(Medusa::DungeonConstructor).to receive(:build!)

      dungeon.claim!(keeper, plan)

      dungeon.minions.each do |minion|
        expect(minion).to be_alive
      end
    end
  end
end
