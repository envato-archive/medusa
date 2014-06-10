require_relative 'client'
require_relative '../keeper'

module Medusa
  module Keepers

    # Manages the connection between the Overlord and a locally running Keeper.
    class LocalClient < Client

      def prepare!(message_handler)
        @message_handler = message_handler

        @logger.debug("Preparing a Keeper")

        @status = "initializing"

        @keeper = Keeper.new(self)
        @keeper.create_dungeon!
        @keeper.spawn_minions!

        @status = "initialized"
      end

      def send_message(message)
        @keeper.handle_command(message)
      end

      def handle_message(message)
        @message_handler.handle_message(message, self)
      end

      def work!
        @status = "running"
        @keeper.work!
      end

    end
  end
end