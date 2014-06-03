require 'spec_helper'

describe Medusa::MessageStream do

  class TestMessage < Medusa::Message
  end

  let(:transport) { double("TestTransport") }
  let(:stream) { described_class.new(transport) }

  describe "#wait_for_message" do
    it "returns a message from the stream" do
      puts RSpec::Version::STRING
      expect(transport).to receive(:read).and_return(TestMessage.new.serialize)
      expect(stream.wait_for_message).to be_a(TestMessage)
    end

    it "ignores bad data in the stream" do
      expect(transport).to receive(:read).and_return("naughty message")
      expect(transport).to receive(:read).and_return(TestMessage.new.serialize)
      expect(stream.wait_for_message).to be_a(TestMessage)
    end
  end

  describe "#send_message" do
    it "serializes a message to the transport" do
      expect(transport).to receive(:write).with(TestMessage.new.serialize)
      stream.send_message(TestMessage.new)
    end

    it "raises UnprocessableMessage if not a message" do
      expect { stream.send_message("naughty message") }.to raise_error(Medusa::MessageStream::UnprocessableMessage)
    end
  end
end