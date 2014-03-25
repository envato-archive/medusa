module Medusa
  module Initializers
    class Ruby < Abstract

      def run(command_stream)
        command_stream.execute_as_channel("ruby -v")
      end

    end
  end
end