if defined?(Medusa::Teamcity::Messenger)
  module Medusa
    module Reporters
      class Teamcity < Medusa::Reporters::Abstract
        def initialize(output = $stdout)
          super(output)
          @teamcity_messenger = Medusa::Teamcity::Messenger.new
        end

        def example_group_started(group_name)
          @teamcity_messenger.notify_example_group_started(group_name)
        end

        def example_group_finished(group_name)
          @teamcity_messenger.notify_example_group_finished(group_name)
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
end
