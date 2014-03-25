module Medusa
  module Listener
    class Teamcity < Medusa::Listener::Abstract
      def initialize(output = $stdout)
        super(output)
        @teamcity_messenger = Medusa::Teamcity::Messenger.new
      end

      def file_begin(file)
        @teamcity_messenger.notify_example_group_started(file)
      end

      def file_end(file)
        @teamcity_messenger.notify_example_group_finished(file)
      end

      def file_summary(summary)
        @teamcity_messenger.notify_example_group_summary(summary)
      end

      def example_begin(example_name)
        @teamcity_messenger.notify_example_started(example_name)
      end

      def result_received(file, result)
        @teamcity_messenger.notify_example_finished(file, result)
      end
    end
  end
end

