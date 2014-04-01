module Medusa
  class LocalConnection

    attr_reader :runners, :worker_id
    attr_accessor :medusa_pid

    def initialize(runners)
      @port = TcpTransport.next_available_port + 100
      @runners = runners
      @worker_id = rand(1000000)
    end

    def exec(command, &output_handler)
      r, w = IO.pipe
      pid = Process.spawn(command, :out => w, :err => w)

      while true
        termination_status = Process.wait(pid, Process::WNOHANG)
        return $?.exitstatus if termination_status

        buffer = begin
          r.read_nonblock(100_000)
        rescue IO::WaitReadable
          nil
        end

        yield buffer if block_given? && buffer        
      end

    ensure
      r.close rescue nil
      w.close rescue nil
    end

    def target
      user = `who am i`.split(/\s+/).first
      "/tmp/medusa/local-#{user}-#{@port}"
    end

    def work_path
      Pathname.new(target)
    end

    def terminate!
      
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