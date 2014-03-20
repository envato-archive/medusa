module Medusa
  module Drivers
    class EventIO

      def on_output(&block)
        @on_output = block
      end

      def puts(message)
        @on_output.call(message)
      end

    end
  end
end