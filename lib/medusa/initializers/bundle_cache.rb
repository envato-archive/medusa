module Medusa
  module Initializers
    class BundleCache

      # This command runs within the dungeon process, installing the bundle and then
      # requiring it.
      class BundleInstallCommand
        def execute(dungeon, reporter)
          location = dungeon.location

          command = "cd #{location}; bundle --path #{location.join(".bundle")}"

          result = run_command(command, reporter)

          Dir.chdir(location.to_s)
          require 'bundler'
          Bundler.require

        rescue => ex
          ::Medusa.logger.tagged(self.class.name).error(ex.to_s)
          ::Medusa.logger.tagged(self.class.name).error(ex.backtrace)
          raise
        end

        def run_command(command, reporter)
          r, w = IO.pipe
          pid = Process.spawn(command, :out => w, :err => w)

          while true
            termination_status = Process.wait(pid, Process::WNOHANG)
            return $?.exitstatus if termination_status

            buffer = begin
              r.read_nonblock(100_000)
            rescue IO::WaitReadable
              ""
            end

            lines = buffer.split("\n")

            lines.each do |line|
              next if line.to_s.strip.length == 0
              reporter.report(Messages::InitializerMessage.new(initializer: "BundleCache", output: line))
            end
          end
        end
      end

      # Executes a bundle install on the Dungeon.
      def execute(keeper, dungeon)
        dungeon.build!(BundleInstallCommand.new, keeper)
      end

    end
  end
end
