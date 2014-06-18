require 'spec_helper'

require_relative '../lib/medusa/minion'

describe Medusa::Minion do
  let(:dungeon) { double("Dungeon", name: "Test", location: Pathname.new("/tmp/medusa-test")) }
  let(:keeper) { double("Keeper", name: "Lord Testable") }

  subject(:minion) { described_class.new(dungeon, 1) }

  describe "#receive_the_gift_of_life!" do
    let(:plan) { [] }

    it "becomes alive" do
      expect(minion).to_not be_alive
      minion.receive_the_gift_of_life!(keeper)
      expect(minion).to be_alive
    end

    it "receives training" do
      expect(Medusa::MinionTrainer).to receive(:train!).with(minion, plan)
      minion.receive_the_gift_of_life!(keeper, plan)
    end
  end

  describe "#work!" do
    let(:driver) { double("Driver", execute: true) }
    let(:reporter) { double("Reporter", report: true) }

    it "delegates to the correct driver" do
      expect(Medusa::Drivers::Acceptor).to receive(:accept?).with("/tmp/medusa-test/some_file.rb").and_return(driver)

      minion.report_to(reporter)
      minion.work!("some_file.rb")

      expect(driver).to have_received(:execute).with("/tmp/medusa-test/some_file.rb", reporter)
    end
  end
end
