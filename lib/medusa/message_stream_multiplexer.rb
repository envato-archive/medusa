module Medusa

  # Groups a number of message streams and merges their received message stream into
  # one for single threaded handling.
  class MessageStreamMultiplexer

    def initialize
      @streams = {}
      @received_messages = Queue.new
    end

    def on_message(&block)
      @message_handler = block
    end

    def on_stream_lost(&block)
      @disconnection_handler = block
    end

    def <<(stream)
      @streams[stream] = init_stream_thread(stream)
    end

    def stop!
      @stopped = true
      @streams.values.each(&:exit)
      @streams.keys.each { |s| s.close rescue nil }
      @streams.clear
      @received_messages << [:stop]
    end

    def run!
      loop do
        # sleep(0.1) while @received_messages.empty?

        event = begin
          Timeout.timeout(0.1) do
            @received_messages.pop
          end
        rescue Timeout::Error
          []
        end

        if event.first == :message
          @message_handler.call(event[1], event[2]) if @message_handler
        elsif event.first == :disconnect
          @streams.delete(event.last)
          @disconnection_handler.call(event.last, @streams.length) if @disconnection_handler
        end

        return if @streams.empty? || @stopped
      end
    end

    private

    def init_stream_thread(s)
      Thread.start(s) do |stream|
        begin
          loop do
            message = stream.wait_for_message
            @received_messages << [:message, message, stream] if message
          end
        rescue IOError
          puts "Received disconnect"
          @received_messages << [:disconnect, stream]
        rescue => ex
          puts "ERROR: #{ex.to_s}"
        end
      end
    end
  end
end