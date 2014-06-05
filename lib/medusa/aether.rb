module Medusa
  def self.aether
    Aether.new
  end

  # All things communicate over the Aether. Didn't you know?
  class Aether

    def initialize(last_aether = nil)
      @last_aether = last_aether
    end

    def conduit(subject)
      
    end

    def on_command_received(&block)
      @command_handler = block
    end

    def on_message_received
      @message_handler = block
    end

    def send_message(message)
      
    end

    def send_command(command)
      
    end

    class Tendril

    end
  end
end