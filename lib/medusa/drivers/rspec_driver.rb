module Medusa
  module Drivers
    class RspecDriver < Abstract
      REDIRECTION_FILE = "/tmp/rspec-output.log"

      def self.accept?(file)
        file =~ /_spec\.rb$/
      end

      def execute(file)
        conduit = Pipe.new

        pid = fork do
          conduit.identify_as_child

          require 'rspec'
          require 'medusa/spec/medusa_formatter'

          err = StringIO.new

          medusa_output = EventIO.new

          medusa_output.on_output do |message|
            conduit.write message
          end

          STDOUT.reopen(REDIRECTION_FILE)
          STDERR.reopen(REDIRECTION_FILE)

          RSpec::Core::Runner.run(["-fRSpec::Core::Formatters::MedusaFormatter", file.to_s], err, medusa_output)
        end

        conduit.identify_as_parent

        while Process.wait(pid, Process::WNOHANG).nil?
          message = conduit.gets
          message_bus.write message if message
        end

      ensure
        conduit.close
      end

    end
  end
end
