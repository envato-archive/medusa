require 'spec_helper'

require_relative '../lib/medusa/dungeon'
require_relative '../lib/medusa/dungeon_plan'

describe Medusa::Dungeon do
  subject(:dungeon) { described_class.new }

  describe "#claim!" do
    let(:plan) { Medusa::DungeonPlan.new }
    let(:keeper) { Medusa::Keeper.new }

    it "constructs the Dungeon" do
      dungeon.claim!(keeper, plan)
      expect(dungeon.keeper).to eql keeper
    end
  end

  describe "#fit_out!" do
    let(:plan) { Medusa::DungeonPlan.new }
    let(:keeper) { Medusa::Keeper.new }

    before do
      dungeon.claim!(keeper, plan)
    end

    it "constructs the Dungeon" do
      expect(Medusa::DungeonConstructor).to receive(:build!).with(dungeon, plan.blueprints)
      dungeon.fit_out!
    end

    it "returns a union representative" do
      allow(Medusa::DungeonConstructor).to receive(:build!)

      union = dungeon.fit_out!
      expect(union).to be_a(Medusa::Union)
    end
  end
end
