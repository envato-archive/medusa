require 'spec_helper'
require 'benchmark'

describe Medusa::TcpTransport do
  describe "Client/Server communication" do
    it "waits for a client connection and can transfer messages" do
      begin
        server = described_class.new("localhost", 20000)

        Thread.new do 
          server.server!
          server.write("Hi!")
        end

        client = described_class.new("localhost", 20000)
        expect(client.read).to eql("Hi!")
      ensure
        client.close
        server.close
      end
    end
  end

  describe "Client connection" do
    it "waits for a server connection and can transfer messages" do
      begin
        server = described_class.new("localhost", 20000)

        Thread.new do 
          sleep(0.2)
          server.server!
          server.write("Hi!")
        end

        client = described_class.new("localhost", 20000)

        time_taken = Benchmark.measure do
          expect(client.read).to eql("Hi!")
        end

        time_taken.real.should > 0.2
      ensure
        client.close
        server.close
      end
    end

    it "times out the connection after given timeout" do      
      client = described_class.new("localhost", 20000, 0.5)

      time = Benchmark.measure do
        expect { client.read }.to raise_error(Errno::ECONNREFUSED)
      end

      time.real.should > 0.5
      time.real.should < 0.8
    end
  end

  describe "Server Disconnection" do
    it "raises an IOError in the client" do
      begin
        server = described_class.new("localhost", 20000)

        Thread.new do 
          server.server!
          sleep(0.2)
          server.close
        end

        client = described_class.new("localhost", 20000)
        expect { client.read }.to raise_error(IOError)
      end
    end
  end
end