require_relative 'abstract'

module Medusa
  module Drivers
    class ForkedRspecDriver < Abstract
      REDIRECTION_FILE = "/tmp/rspec-output.log"

      def self.accept?(file)
        file =~ /_spec\.rb$/
      end

      def execute(file, minion)
        require 'rspec'
        require 'medusa/spec/medusa_formatter'
        
        parent, child = PipeTransport.pair

        pid = fork do
          $0 = "[medusa] RspecDriver Running: #{file}"

          err = StringIO.new

          medusa_output = EventIO.new
          message_stream = MessageStream.new(child)
          logger = Medusa.logger.tagged("#{self.class.name} - Child")
          sent_messages = 0

          medusa_output.on_output do |message|
            logger.debug("Send message #{message.class}")
            sent_messages += 1
            message_stream.send_message message if message.is_a?(Message)
          end

          begin
            RSpec::Core::Formatters::MedusaFormatter.with_stdout do
              RSpec::Core::Runner.run(["-fRSpec::Core::Formatters::MedusaFormatter", file.to_s], err, medusa_output)
            end

            # sleep(10)
            logger.debug("Child complete")
          rescue Object => ex
            logger.debug("Child error - #{ex.to_s}")
            message_stream.send_message(Messages::TestResult.fatal_error(file, ex))
          ensure
            message_stream.send_message Messages::Ping.new
            message_stream.close
          end

          logger.debug("Child terminating #{sent_messages}")
        end

        $0 = "[medusa] RspecDriver Listening: #{file}"

        parent_stream = MessageStream.new(parent)
        logger = Medusa.logger.tagged("#{self.class.name} - Parent waiting in #{pid}")
        received_messages = 0

        while true # Process.wait(pid, Process::WNOHANG).nil? # Process.wait is unreliable because the child ends before we get all the messages.
          begin
            message = parent_stream.wait_for_message
            received_messages += 1
            logger.debug("From child #{message.class.name}")
            if message.is_a?(Messages::TestResult)
              minion.inform_work_result message
            elsif message.is_a?(Messages::Ping)
              break
            end
          rescue => ex
            logger.debug("Error: #{ex.to_s}")
          end
        end

        logger.debug("We're done - #{received_messages}")

      ensure
        parent_stream.close rescue nil
      end

    end
  end
end
