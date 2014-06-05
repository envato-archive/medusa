require 'spec_helper'

require_relative '../lib/medusa/keeper'

describe Medusa::Keeper do
  subject(:keeper) { described_class.new }
  let(:overlord) { double("Overlord") }
  let(:dungeon) { double("Dungeon", fit_out: [minion]) }
  let(:minion) { double("Minion") }

  describe "#serve!" do
    it "is named by the Overlord" do
      keeper.serve!(overlord, "Barry")
      expect(keeper.name).to eql "Barry"
    end

    it "serves the Overlord" do
      keeper.serve!(overlord, "Barry")
      expect(keeper.overlord).to eql overlord
    end
  end

  describe "#claim!" do
    it "claims a dungeon" do
      keeper.claim!(dungeon)
      expect(dungeon).to have_received(:fit_out)
    end

    it "knows the minions of the dungeon" do
      keeper.claim!(dungeon)
      expect(keeper.minions).to eql([minion])
    end
  end

  describe "#work!" do
    let(:minion) { double("Minion", :work! => true) }
    let(:dungeon) { double("Dungeon", :fit_out => [minion]) }

    before do
      keeper.claim!(dungeon)
    end

    it "returns true if work commenced" do
      result = keeper.work!("some_file.rb")

      expect(minion).to have_received(:work!).with("some_file.rb", instance_of(Medusa::KeeperAmbassador))
      expect(result).to be_true
    end

    it "returns false if no minions free" do
      keeper.work!("some_file.rb")
      result = keeper.work!("some_file.rb")

      expect(minion).to have_received(:work!).once
      expect(result).to be_false
    end
  end

  describe "#inform_work_complete" do
    it "informs the overlord"
  end

  describe "#inform_work_result" do
    it "informs the overlord"
  end
end
