module Medusa
  module Drivers
    class RspecDriver < Abstract
      REDIRECTION_FILE = "/tmp/rspec-output.log"

      def self.accept?(file)
        file =~ /_spec\.rb$/
      end

      def execute(file, minion)
        parent, child = PipeTransport.pair

        pid = fork do
          require 'rspec'
          require 'medusa/spec/medusa_formatter'

          $0 = "[medusa] RspecDriver Running: #{file}"

          err = StringIO.new

          medusa_output = EventIO.new
          message_stream = MessageStream.new(child)

          medusa_output.on_output do |message|
            message_stream.send_message message if message.is_a?(Message)
          end

          begin
            RSpec::Core::Formatters::MedusaFormatter.with_stdout do
              RSpec::Core::Runner.run(["-fRSpec::Core::Formatters::MedusaFormatter", file.to_s], err, medusa_output)
            end
          rescue Object => ex
            message_stream.write(Messages::TestResult.fatal_error(file, ex))
          ensure
            message_stream.close
          end
        end

        $0 = "[medusa] RspecDriver Listening: #{file}"

        parent_stream = MessageStream.new(parent)

        while Process.wait(pid, Process::WNOHANG).nil?
          begin
            Timeout.timeout(0.1) do
              message = parent_stream.wait_for_message
              minion.handle_message message if message.is_a?(Message)
            end
          rescue Timeout::Error
          end
        end

      ensure
        parent_stream.close rescue nil
      end

    end
  end
end
