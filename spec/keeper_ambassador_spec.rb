require 'spec_helper'

require_relative '../lib/medusa/keeper_ambassador'

describe Medusa::KeeperAmbassador do
  subject(:ambassador) { described_class.new(keeper, minions) }
  let(:keeper) { double("Keeper", inform_work_complete: true, inform_work_result: true) }
  let(:minions) { [minion] }
  let(:minion) { double("Minion", work!: true)}

  describe "#delegate_work!" do
    it "returns true when there's a free minion" do
      result = ambassador.delegate_work!("file.rb")
      expect(minion).to have_received(:work!).with("file.rb", instance_of(Medusa::KeeperAmbassador))
      expect(result).to be_true
    end

    it "returns false when there's no free minions" do
      ambassador.delegate_work!("file.rb")

      result = ambassador.delegate_work!("file.rb")
      expect(minion).to have_received(:work!).once
      expect(result).to be_false
    end
  end

  describe "#work_remains?" do
    it "returns true if minions are working" do
      ambassador.delegate_work!("file.rb")
      expect(ambassador).to be_work_remains
    end

    it "returns false if no minions are working" do
      expect(ambassador).to_not be_work_remains
    end

    it "returns false after a working minion finishes" do
      ambassador.delegate_work!("file.rb")
      ambassador.inform_work_complete("file.rb", minion)
      expect(ambassador).to_not be_work_remains
    end
  end

  describe "#inform_work_complete" do
    it "informs the Keeper" do
      ambassador.inform_work_complete("file.rb", minion)
      expect(keeper).to have_received(:inform_work_complete).with("file.rb")
    end
  end

  describe "#inform_work_result" do
    it "informs the Keeper" do
      result = "Some Result"

      ambassador.inform_work_result(result)
      expect(keeper).to have_received(:inform_work_result).with(result)
    end
  end
end

