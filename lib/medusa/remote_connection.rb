
module Medusa
  class RemoteConnection
    traceable('REMOTE')

    def self.from_target(target)
      user = nil
      host = nil

      if target.include?("@")
        user = target.split("@").first
        host = target.split("@").last
      else
        host = target
      end

      new(host, user)      
    end

    def initialize(host, username = nil)
      
      require 'net/ssh'

      @host = host
      @username = username
      @port = TcpTransport.next_available_port

      puts "Opening remote connection to #{host}"
      puts "  User: #{@username}"
      puts "  Comms Port: #{@port} (local) -> #{host}:#{@port + 200}"

      transport = TcpTransport.new("localhost", @port)
      transport.server!


      @session = Net::SSH.start(@host, @username, :password => "pop632")
      @session.forward.remote_to(@port, 'localhost', @port + 200)

      # Blocking accept
      Thread.new { transport.read }

      @message_stream = MessageStream.new(transport)

      @looping_thread = Thread.new { loop { @session.loop { true }; sleep(0.1); } }
    end

    def exec(command, &output_handler)
      @session.process.open(command) do |process|
        process.on_stdout do |p, data|
          output_handler.call(data) if output_handler
        end
      end
    end

    def exec_and_detach(command, &output_handler)
      @session.open_channel do |ch|

        ch.on_data do |x, data|
          output_handler.call(data) if output_handler          
        end

        ch.on_extended_data do |x, i, data|
          output_handler.call(data) if output_handler
        end

        ch.on_close do |x|
          raise "CLOSE!"
        end

        ch.exec command
      end
    end

    def forwarded_port
      @port + 200
    end

    def message_stream
      @message_stream ||= begin
        transport = TcpTransport.new("localhost", @port)
        transport.server!
        MessageStream.new(transport)
      end
    end

    def close
      @session.close
      @message_stream.close if @message_stream
      # @looping_thread.kill
    end
  end
end