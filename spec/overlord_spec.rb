require 'spec_helper'

class DummyKeeperClient
  attr_reader :status, :message_handler

  def initialize
    @status = "uninitialized"
  end

  def prepare!(message_handler)
    @status = "ready"
    @message_handler = message_handler
  end

  def send_message(message)
    @messages ||= []
    @messages << message
  end

  def last_message_sent
    @messages.last
  end

end

describe Medusa::Overlord do
  subject(:overlord) { described_class.new }

  after do
    overlord.shutdown!
  end

  describe "#keepers" do
    it "acts like an array" do
      dummy_worker = DummyKeeperClient.new
      overlord.keepers << dummy_worker
      expect(overlord.keepers).to eql [dummy_worker]
    end
  end

  describe "#prepare!" do
    it "should start all the keepers" do
      overlord.keepers << DummyKeeperClient.new
      overlord.keepers << DummyKeeperClient.new

      overlord.prepare!

      expect(overlord.keepers.collect(&:status)).to eql ["ready", "ready"]
    end

    it "should setup keeper message streams" do
      overlord.keepers << DummyKeeperClient.new
      overlord.keepers << DummyKeeperClient.new

      overlord.prepare!

      expect(overlord.keepers.collect(&:message_handler)).to eql [overlord, overlord]
    end
  end

  describe "#add_work" do
    it "adds arrays to the queue" do
      overlord.add_work(["some_file.rb", "some_other_file.rb"], "this_file.rb")
      expect(overlord.work).to eql ["some_file.rb", "some_other_file.rb", "this_file.rb"]
    end
  end

  context "message handling" do
    let(:client) { DummyKeeperClient.new }

    describe Medusa::Messages::RequestFile do

      it "provides work when asked" do
        overlord.add_work("file1.rb", "file2.rb")

        overlord.handle_message(Medusa::Messages::RequestFile.new, client)

        last_message = client.last_message_sent

        expect(last_message).to be_a(Medusa::Messages::RunFile)
        expect(last_message.file).to eql "file1.rb"
      end

      it "marks a file as being in progress" do
        overlord.add_work("file1.rb", "file2.rb")

        overlord.handle_message(Medusa::Messages::RequestFile.new, client)

        expect(overlord.work_in_progress).to include("file1.rb")
      end

    end

    describe Medusa::Messages::TestResult do

      before do
        overlord.add_work("file1.rb", "file2.rb")
        overlord.handle_message(Medusa::Messages::RequestFile.new, client)
      end

      it "marks a file as complete" do
        overlord.handle_message(Medusa::Messages::TestResult.new(name: "file1.rb"), client)

        expect(overlord.work_in_progress).to_not include("file1.rb")
        expect(overlord.work_complete).to include("file1.rb")
      end

    end
  end

end
