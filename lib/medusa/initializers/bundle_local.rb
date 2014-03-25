module Medusa
  module Initializers
    class BundleLocal < Abstract
      def run(command_stream)
        master.initializer_start("bundle --local --path .bundle", worker)

        result = command_stream.execute_and_wait("bundle --local --path .bundle\n")

        master.initializer_result(result, worker)
      end
    end
  end
end