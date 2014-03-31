module Medusa
  module Initializers
    class BundleCache < Abstract
      def run(connection, master, worker)
        result = Result.new("bundle --path .bundle")

        status = connection.exec("bundle --path .bundle") do |output|
          master.initializer_output(worker, self, output)
          result << output
        end

        result.exit_status = status

        return result
      end
    end
  end
end