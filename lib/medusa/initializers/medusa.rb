module Medusa
  module Initializers
    class Medusa < Abstract

      def run(connection, master, worker)
        connection.exec("mkdir -p #{connection.work_path}")

        command = "cd #{connection.work_path} && bundle exec "

        command += ENV["MEDUSA_BIN"] || "medusa"

        command += " worker --connect-tcp localhost:#{connection.forwarded_port} --runners #{connection.runners} --id #{connection.worker_id}"
        result = Result.new(command)

        puts command
        puts "Logging"
        log(master, worker, "Starting...")

        puts "Executing"

        begin
          connection.medusa_pid = connection.exec_and_detach(command) do |message|
            puts message
          end

          puts "Waiting until alive #{connection.medusa_pid}"

          wait_until_alive(connection)

          result.exit_status = connection.medusa_pid.to_i != 0 ? 0 : -1
        rescue Timeout::Error => ex
          result << "Worker didn't respond in time"
          result.exit_status = -1
        rescue Errno::ENOENT => ex
          result << "Is medusa installed on #{connection.target}?"
        end

        puts "Done. #{result.inspect}"

        return result
      end

      def wait_until_alive(connection)
        Timeout.timeout(4) do
          connection.message_stream.wait_for_message
        end
      end

    end
  end
end