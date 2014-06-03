module Medusa
  module Initializers
    class BundleCache < Abstract
      def run(connection, master, worker)
        result = Result.new("cd #{connection.work_path} && bundle --path #{connection.work_path.join(".bundle")}")

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