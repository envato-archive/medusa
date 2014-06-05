require 'spec_helper'

require_relative '../lib/medusa/keeper'

describe Medusa::Keeper do
  subject(:keeper) { described_class.new }
  let(:overlord) { double("Overlord") }
  let(:dungeon) { double("Dungeon", fit_out: [minion]) }
  let(:minion) { double("Minion") }

  describe "#serve!" do
    before do
      expect(Medusa::DungeonDiscovery).to receive(:claim!).with(keeper).and_return(dungeon)
    end

    it "claims a dungeon" do
      keeper.serve!(overlord, "Barry")
      expect(dungeon).to have_received(:fit_out)
    end

    it "knows the minions of the dungeon" do
      keeper.serve!(overlord, "Barry")
      expect(keeper.minions).to eql([minion])
    end

    it "is named by the Overlord" do
      keeper.serve!(overlord, "Barry")
      expect(keeper.name).to eql "Barry"
    end
  end

  describe "#work!" do
    
  end
end
