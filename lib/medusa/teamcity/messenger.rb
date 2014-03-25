begin
  require '/Users/pablolee/src/rake-runner/rb/patch/bdd'
  require '/Users/pablolee/src/rake-runner/rb/patch/common'
rescue LoadError
end

if defined?(::Rake::TeamCity::RunnerCommon)
  module Medusa
    module Teamcity
      class Messenger
        include ::Rake::TeamCity::RunnerCommon

        def notify_example_group_started(group_name)
          send_msg(::Rake::TeamCity::MessageFactory.create_suite_started(group_name, ''))
        end

        def notify_example_group_finished(group_name)
          send_msg(::Rake::TeamCity::MessageFactory.create_suite_finished(group_name))
        end

        def notify_example_group_summary(summary)
          # send_msg(summary)
        end

        def notify_example_started(example_name)
          send_msg(::Rake::TeamCity::MessageFactory.create_test_started(example_name, ''))
        end

        def notify_example_finished(file, result)
          send_msg(::Rake::TeamCity::MessageFactory.create_test_finished(result.description, nil, nil))

          if result.failure? || result.fatal?
            notify_failure(result)
          elsif result.pending?
            notify_pending(result)
          end
        end

        private

        def notify_success(result)
        end

        def notify_failure(result)
          send_msg(::Rake::TeamCity::MessageFactory.create_test_failed(result.description, result.exception, result.exception_backtrace))
        end

        def notify_pending(result)
          send_msg(::Rake::TeamCity::MessageFactory.create_test_ignored(result.description, ''))
        end
      end
    end
  end
end

