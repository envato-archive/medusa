
module Medusa
  module Drivers
    class RspecDriver
      def initialize
        @logger = Medusa.logger.tagged(self.class.name)
      end

      def accept?(file)
        file =~ /_spec\.rb$/
      end

      def execute(file, reporter)
        require 'rspec'
        require 'medusa/spec/medusa_formatter'

        pid = fork do
          $0 = "[medusa] RSpec Driver - #{file}"

          @logger.debug("Forked")

          err = StringIO.new
          medusa_output = EventIO.new

          medusa_output.on_output do |message|
            @logger.debug("Reporting message #{message.class.name}")
            reporter.report message
            @logger.debug("Message reported successfully.")
          end

          RSpec.configuration = RSpec::Core::Configuration.new
          RSpec.world = RSpec::Core::World.new

          # If there's some kind of terminal error on the parent, shutdown the child.
          Thread.abort_on_exception = true
          Thread.new do
            watcher = ParentTerminationWatcher.new
            watcher.block_until_parent_dead!
            raise RuntimeError
          end

          begin
            RSpec::Core::Formatters::MedusaFormatter.with_stdout do
              RSpec::Core::Runner.run(["-fRSpec::Core::Formatters::MedusaFormatter", file.to_s], err, medusa_output)
            end
          rescue Object => ex
            reporter.report(Messages::TestResult.fatal_error(file, ex))
          end
        end

        @logger.debug("Waiting for process #{pid} to finish...")
        Process.wait(pid)
      end
    end
  end
end
