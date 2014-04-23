module Medusa
  module Initializers
    class RSync < Abstract
      def run(connection, master, worker)
        # We don't need to rsync for a local worker.
        return Result.success if connection.is_a?(LocalConnection)

        result = Result.new("rsync -avz --delete --exclude .git --exclude medusa*.log --exclude .bundle #{master.project_root}/ #{connection.target}:#{connection.work_path}")

        status = local_exec(result.command) do |output|
          log(master, worker, output)
          puts output
          result << output
        end

        result.exit_status = status
        puts "Rsync done #{status.inspect}"

        return result
      end

      def local_exec(command, &block)
        r, w = IO.pipe
        pid = Process.spawn(command, :out => w, :err => w)

        while true
          termination_status = Process.wait(pid, Process::WNOHANG)
          return $?.exitstatus if termination_status

          buffer = begin
            r.read_nonblock(100_000)
          rescue IO::WaitReadable
            nil
          end

          yield buffer if block_given? && buffer        
        end

      ensure
        r.close rescue nil
        w.close rescue nil
      end
    end
  end
end