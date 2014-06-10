require 'spec_helper'

describe Medusa::Overlord do
  subject(:overlord) { described_class.new }

  let(:keeper_pool) { double("KeeperPool", accept_work!: true, add_keeper: true, prepare!: true) }

  before do
    allow(Medusa::KeeperPool).to receive(:new).and_return(keeper_pool)
  end

  after do
    overlord.shutdown!
  end

  describe "#keepers" do
    let(:keeper) { double("Keeper", :serve! => true) }

    it "acts like an array" do
      overlord.keepers << keeper
      expect(overlord.keepers).to eql [keeper]
    end
  end

  describe "#prepare!" do
    let(:keeper_1) { double("Keeper", :serve! => true, :claim! => true, :name => "Bill") }
    let(:keeper_2) { double("Keeper", :serve! => true, :claim! => true, :name => "Tony") }
    let(:dungeon_1) { double("Dungeon", :name => "Melbourne") }
    let(:dungeon_2) { double("Dungeon", :name => "Sydney") }

    it "should start all the keepers" do
      overlord.keepers << keeper_1
      overlord.keepers << keeper_2

      overlord.prepare!

      expect(keeper_pool).to have_received(:add_keeper).exactly(2).times
      expect(keeper_pool).to have_received(:prepare!).with(overlord).once
    end
  end

  describe "#work!" do
    it "allocates work to pool" do
      keeper_1 = double("Keeper", :free? => false, :work! => true, :working? => false)
      keeper_2 = double("Keeper", :free? => true, :work! => true, :working? => false)

      overlord.keepers << keeper_1
      overlord.keepers << keeper_2

      overlord.add_work("file1.rb", "file2.rb")

      overlord.work!

      expect(keeper_pool).to have_received(:accept_work!).with(["file1.rb", "file2.rb"])
    end

    it "waits until keepers have completed their work"
  end

  describe "#receive_result" do  
    it "distributes the result to reporters" do
      reporter = double("Reporter", :message => true)
      some_message = "Result"

      overlord.reporters << reporter

      overlord.receive_report(some_message)

      expect(reporter).to have_received(:message).with(some_message)
    end
  end

  describe "#add_work" do
    it "adds arrays to the queue" do
      overlord.add_work(["some_file.rb", "some_other_file.rb"], "this_file.rb")
      expect(overlord.work).to eql ["some_file.rb", "some_other_file.rb", "this_file.rb"]
    end
  end


end
