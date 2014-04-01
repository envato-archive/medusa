module Medusa
  module Initializers
    class RSync < Abstract
      def run(connection, master, worker)
        result = Result.new("mkdir -p #{File.dirname(connection.work_path)}")

        status = connection.exec(result.command) do |output|
          master.initializer_output(worker, self, output)
          result << output
        end

        result.exit_status = status

        return result unless result.ok?

        result = Result.new("rsync -avz --delete #{master.project_root}/* #{connection.target}")

        status = connection.exec(result.command) do |output|
          master.initializer_output(worker, self, output)
          result << output
        end

        result.exit_status = status

        return result
      end
    end
  end
end