module Medusa

  # The worker maintains a list of runner clients, which are connected to actual runners.
  class RunnerClient

    attr_reader :id, :process_id, :message_stream

    def initialize(id)
      @id = id
      @free = true
      @ready = false
    end

    def send_message(message)
      @message_stream.send_message(message)
    end

    def ready?
      !!@ready
    end

    def free?
      !!@free
    end

    def free=(value)
      @free = value
    end

    def ready=(value)
      @ready = value
      @free = value
    end

    def boot!
      transport = TcpTransport.new("localhost", 19100 + self.id)
      port = transport.port

      @process_id = fork do
        child_stream = MessageStream.new(TcpTransport.new("localhost", port))
        Medusa::Runner.new(:id => id, :io => child_stream)
      end

      transport.server!
      @message_stream = MessageStream.new(transport)
    end
  end
end