
module Medusa
  class RemoteConnection
    traceable('REMOTE')

    attr_reader :worker_id, :runners
    attr_accessor :medusa_pid

    def self.from_target(target)
      user = nil
      host = nil
      runners = 1

      if target.include?("@")
        user = target.split("@").first
        host = target.split("@").last
      else
        host = target
      end

      if host.include?("/")
        runners = host.split("/").last.to_i
        host = host.split("/").first
      end

      new(host, user, runners)      
    end

    def initialize(host, username, runners)
      
      require 'net/ssh'

      @host = host
      @username = username || current_user
      @port = TcpTransport.next_available_port
      @runners = runners

      puts "Opening remote connection to #{host}"
      puts "  User: #{@username}"
      puts "  Comms Port: #{@port} (local) -> #{host}:#{@port + 200}"

      # transport = TcpTransport.new("localhost", @port)
      # transport.server!

      @session = Net::SSH.start(@host, @username)
      @session.forward.remote_to(@port, 'localhost', @port + 200)

      # Blocking accept
      # Thread.new { transport.read }

      # @message_stream = MessageStream.new(transport)

      @worker_id = rand(1000000)
    end

    def exec(command, &output_handler)
      puts "EXEC #{command}"

      @session.open_channel do |channel|
        channel.exec(command) do |ch, success|
          ch.on_close do |p|
            puts "CLOSED"
          end

          ch.on_extended_data do |p,type,data|
            puts data
          end

          ch.on_data do |p, data|
            puts data
            output_handler.call(data) if output_handler
          end

          return -1 unless success
        end

        channel.wait
      end

      return 0
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

      @looping_thread ||= Thread.new { loop { @session.loop { true }; sleep(0.1); } }

      1
    end

    def forwarded_port
      @port + 200
    end

    def port
      @port
    end

    def target
      [@username, @host].reject(&:empty?).join("@")
    end

    def work_path
      Pathname.new("/tmp/medusa/#{current_user}-#{@port}").expand_path
    end    

    def message_stream
      @message_stream ||= begin
        transport = TcpTransport.new("localhost", @port)
        transport.server!
        MessageStream.new(transport)
      end
    end

    def close
      @looping_thread.kill if @looping_thread
      @session.close
      @message_stream.close if @message_stream
    end

    def terminate!
      close
    end

    private

    def current_user
      `who am I`.chomp.split(" ").first
    end
  end
end