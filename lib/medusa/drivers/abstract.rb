module Medusa
  module Drivers
    class Abstract

      attr_reader :message_bus

      def initialize(message_bus)
        @message_bus = message_bus
      end

    end
  end
end