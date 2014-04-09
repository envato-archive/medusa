module Medusa
  class WorkerInitializer

    def initialize(worker)
      @worker = worker  
    end

    def exec(command)
      @worker.io.send_message(Messages::Worker::InitializerMessage.new(:initializer => "<WorkerInitializer> #{self.class.name}", :output => command))

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

        @worker.io.send_message(Messages::Worker::InitializerMessage.new(:initializer => "<WorkerInitializer> #{self.class.name}", :output => buffer)) unless buffer.nil?
      end
    ensure
      r.close rescue nil
      w.close rescue nil
    end

    def log(string)
      @worker.io.send_message(Messages::Worker::InitializerMessage.new(:initializer => "<WorkerInitializer> #{self.class.name}", :output => string))
    end

    def run_initializer
      run
    end

    def ok?
      @error.nil?
    end

    def error
      @error
    end

  end
end