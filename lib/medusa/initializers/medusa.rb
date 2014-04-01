module Medusa
  module Initializers
    class Medusa < Abstract

      def run(connection, master, worker)
        command = "cd #{connection.work_path} && "
        
        command += if File.exist?("bin/medusa")
          "bin/medusa"
        else
          "medusa"
        end

        # command = "/Users/elseano/src/medusa/bin/medusa"

        command += " worker --connect-tcp localhost:#{connection.port} --runners #{connection.runners} --id #{connection.worker_id}"
        result = Result.new(command)

        begin
          connection.medusa_pid = connection.exec_and_detach(command)

          wait_until_alive(connection.message_stream)

          result.exit_status = connection.medusa_pid.to_i != 0 ? 0 : -1
        rescue Timeout::Error => ex
          result << "Worker didn't respond in time"
          result.exit_status = -1
        rescue Errno::ENOENT => ex
          result << "Is medusa installed on #{connection.target}?"
        end

        return result
      end

      def wait_until_alive(message_stream)
        Timeout.timeout(4) do
          message_stream.wait_for_message
        end
      end

    end
  end
end