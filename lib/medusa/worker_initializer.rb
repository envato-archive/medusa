module Medusa
  class WorkerInitializer

    def initialize(worker)
      @worker = worker  
    end

    def exec(command)
      @worker.io.send_message(Messages::Worker::InitializerMessage.new(:output => command))
    end

    def log(string)
      @worker.io.send_message(Messages::Worker::InitializerMessage.new(:output => string))
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