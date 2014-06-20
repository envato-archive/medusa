require 'spec_helper'

require_relative '../lib/medusa/labyrinth_announcer'

class NullLogger

  def debug(*args); end
  def info(*args); end
  def warning(*args); end
  def error(*args); end

end

describe Medusa::LabyrinthAnnouncer do
  let(:tcp_server) { double }
  let(:port) { 9000 }

  subject(:labyrinth_announcer) { described_class.new({ :logger => NullLogger.new }) }

  describe "#announce" do

    before do
      allow(labyrinth_announcer).to receive(:labyrinth_tcp_server).with(port).and_return(tcp_server)
    end

    it "announces itself over DNSSD" do
      expect(DNSSD).to receive(:announce).with(tcp_server, labyrinth_announcer.service_name, labyrinth_announcer.service_type).and_return(true)
      labyrinth_announcer.announce(port)
    end
  end

end
