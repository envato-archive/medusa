require 'test/unit/ui/teamcity/rakerunner_consts'
require 'test/unit/ui/teamcity/message_factory'

module Medusa
  module Teamcity
    class Messenger
      def initialize
        @dispatcher = Rake::TeamCity.msg_dispatcher
        @dispatcher.start_dispatcher
      end

      def notify_test_suite_started(file)
        message = "Starting file #{file}"
        send_message(Rake::TeamCity::MessageFactory.create_progress_message(message))
      end

      def notify_test_suite_finished(file)
        test_name = file
        flow_id_suffix = ''
        send_message(Rake::TeamCity::MessageFactory.create_close_block(test_name, :test, flow_id_suffix))

        # totals = ''
        # send_message(Rake::TeamCity::MessageFactory.create_message(totals))

        duration = ''
        message = "Finished in #{duration} seconds"
        send_message(Rake::TeamCity::MessageFactory.create_progress_message(message))
      end

      def notify_test_started
        flow_id_suffix = ''
        send_message(Rake::TeamCity::MessageFactory.create_flow_message(Rake::TeamCity::MessageFactory::RAKE_FLOW_ID, '', flow_id_suffix))

        test_name = ''
        flow_id_suffix = ''
        send_message(Rake::TeamCity::MessageFactory.create_open_block(test_name, :test, flow_id_suffix))
      end

      def notify_test_finished(file, result)
        test_name = result.description
        flow_id_suffix = ''
        send_message(Rake::TeamCity::MessageFactory.create_close_block(test_name, :test, flow_id_suffix))

        if result.success?
          notify_success(result)
        elsif result.failure?
          notify_failure(result)
        elsif result.pending?
          notify_pending(result)
        end
      end

      private

      def notify_success(result)
        test_name = result.description
        output = ''
        flow_id_suffix = ''
        send_message(Rake::TeamCity::MessageFactory.create_test_output_message(test_name, true, output, flow_id_suffix))
      end

      def notify_failure(result)
        test_name = result.description
        message = result.exception
        failure_description = result.backtrace
        flow_id_suffix = ''
        send_message(Rake::TeamCity::MessageFactory.create_test_problem_message(test_name, message, failure_description, flow_id_suffix))
      end

      def notify_pending(result)
        test_name = result.description
        message = 'test pending'
        flow_id_suffix = ''
        send_message(Rake::TeamCity::MessageFactory.create_test_ignored_message(message, test_name, flow_id_suffix))
      end

      def send_message(msg)
        block = Proc.new { Rake::TeamCity.msg_dispatcher.log_one(msg) }
        ENV[TEAMCITY_RAKERUNNER_LOG_RSPEC_XML_MSFS_KEY] ? SPEC_FORMATTER_LOG.log_block(msg.hash, msg, block) : block.call
      end
    end
  end
end

