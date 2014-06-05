require 'spec_helper'

describe Medusa::Overlord do
  subject(:overlord) { described_class.new }

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
    let(:keeper_1) { double("Keeper", :serve! => true) }
    let(:keeper_2) { double("Keeper", :serve! => true) }

    it "should start all the keepers" do
      overlord.keepers << keeper_1
      overlord.keepers << keeper_2

      overlord.prepare!

      expect(keeper_1).to have_received(:serve!).with(overlord, instance_of(String))
      expect(keeper_2).to have_received(:serve!).with(overlord, instance_of(String))
    end
  end

  describe "#work!" do
    it "allocates work to free keepers" do
      keeper_1 = double("Keeper", :free? => false, :work! => true, :working? => false)
      keeper_2 = double("Keeper", :free? => true, :work! => true, :working? => false)

      overlord.keepers << keeper_1
      overlord.keepers << keeper_2

      overlord.add_work("file1.rb", "file2.rb")

      overlord.work!

      expect(keeper_2).to have_received(:work!).with("file1.rb")
      expect(keeper_2).to have_received(:work!).with("file2.rb")
      expect(keeper_1).to have_received(:work!).exactly(0).times
    end

    it "waits until keepers have completed their work"
  end

  describe "#receive_result" do  
    it "distributes the result to reporters" do
      reporter = double("Reporter", :receive_result => true)
      some_result = double("Result")

      overlord.reporters << reporter

      overlord.receive_result("some_file.rb", some_result)

      expect(reporter).to have_received(:receive_result).with("some_file.rb", some_result)
    end
  end

  describe "#add_work" do
    it "adds arrays to the queue" do
      overlord.add_work(["some_file.rb", "some_other_file.rb"], "this_file.rb")
      expect(overlord.work).to eql ["some_file.rb", "some_other_file.rb", "this_file.rb"]
    end
  end

  # context "message handling" do
  #   let(:client) { DummyKeeperClient.new }

  #   describe Medusa::Messages::RequestFile do

  #     it "provides work when asked" do
  #       overlord.add_work("file1.rb", "file2.rb")

  #       overlord.handle_message(Medusa::Messages::RequestFile.new, client)

  #       last_message = client.last_message_sent

  #       expect(last_message).to be_a(Medusa::Messages::RunFile)
  #       expect(last_message.file).to eql "file1.rb"
  #     end

  #     it "marks a file as being in progress" do
  #       overlord.add_work("file1.rb", "file2.rb")

  #       overlord.handle_message(Medusa::Messages::RequestFile.new, client)

  #       expect(overlord.work_in_progress).to include("file1.rb")
  #     end

  #   end

  #   describe Medusa::Messages::TestResult do

  #     before do
  #       overlord.add_work("file1.rb", "file2.rb")
  #       overlord.handle_message(Medusa::Messages::RequestFile.new, client)
  #     end

  #     it "marks a file as complete" do
  #       overlord.handle_message(Medusa::Messages::TestResult.new(name: "file1.rb"), client)

  #       expect(overlord.work_in_progress).to_not include("file1.rb")
  #       expect(overlord.work_complete).to include("file1.rb")
  #     end

  #   end
  # end

end
