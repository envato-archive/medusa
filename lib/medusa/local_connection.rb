module Medusa
  class LocalConnection

    def initialize
      @port = TcpTransport.next_available_port + 100
    end

    def exec(command, &output_handler)
      pid = Process.spawn(command, :out => w, :err => w)

      while Process.wait(pid, Process::WNOHANG).nil?
        buffer = begin
          r.read_nonblock(100_000)
        rescue IO::WaitReadable
          nil
        end

        yield buffer if block_given? && buffer        
      end

      w.close
    end

    def port
      @port
    end

    def exec_and_detach(command)
      pid = Process.spawn(command)
      Process.detach(pid)
      pid
    end

    def message_stream
      @message_stream ||= begin
        transport = TcpTransport.new("localhost", @port)
        transport.server!
        MessageStream.new(transport)
      end
    end

    def close
      @message_stream.close if @message_stream
    end
  end
end