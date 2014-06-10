module Medusa
  module Keepers
    class Client
      attr_reader :status

      def initialize
        @status = "uninitialized"
        @logger = Medusa.logger.tagged(self.class.name)
      end

      def prepare!(message_stream)
        raise NotImplementedError
      end
    end
  end
end