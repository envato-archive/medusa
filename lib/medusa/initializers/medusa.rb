module Medusa
  module Initializers
    class Medusa < Abstract

      def run(connection, master, worker)
        command = "bin/medusa worker --connect-tcp localhost:#{connection.port} --runners #{connection.runners}"
        result = Result.new(command)

        connection.medusa_pid = connection.exec_and_detach(command)

        result.exit_status = connection.medusa_pid.to_i != 0 ? 0 : -1
        return result
      end

    end
  end
end