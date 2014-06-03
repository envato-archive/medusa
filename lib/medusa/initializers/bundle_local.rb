module Medusa
  module Initializers
    class BundleLocal < Abstract
      def run(connection, master, worker)
        result = Result.new("cd #{connection.work_path} && bundle --local --path .bundle")

        status = connection.exec(result.command) do |output|
          log(master, worker, output)
          result << output
        end

        result.exit_status = status

        return result
      end
    end
  end
end