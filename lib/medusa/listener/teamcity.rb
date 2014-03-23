module Medusa
  module Listener
    class Teamcity < Medusa::Listener::Abstract
      def initialize(output = $stdout)
        super(output)

        @teamcity_messenger = Medusa::Teamcity::Messenger
      end

      # Fired when a file is started
      def file_begin(file)
        @teamcity_messenger.notify_test_suite_started(file)
        # notify_test_started
      end

      # Fired when a file is finished
      def file_end(file)
        @teamcity_messenger.notify_test_suite_finished(file)
      end

      # Fired every time we receive a result from a runner.
      def result_received(file, result)
        @teamcity_messenger.notify_test_finished
      end
    end
  end
end

