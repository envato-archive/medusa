module Medusa
  module Initializers
    class RSync < Abstract
      def run(connection, master, worker)
        result = Result.new("mkdir -p #{connection.work_path.dirname}")

        status = connection.exec(result.command) do |output|
          log(master, worker, output)
          result << output
        end

        result.exit_status = status

        return result unless result.ok?

        result = Result.new("rsync -avz --delete --exclude .git #{master.project_root}/ #{connection.target}")

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