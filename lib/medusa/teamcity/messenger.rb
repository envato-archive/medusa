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

        def notify_example_group_started(example_group)
          count = example_group.count
          description = example_group.description

          # send_msg(::Rake::TeamCity::MessageFactory.create_progress_message("Starting.. (#{count} examples)"))
          # send_msg(::Rake::TeamCity::MessageFactory.create_suite_started(description, ''))
        end

        def notify_example_group_finished(example_group)
          description = example_group.description
          # send_msg(::Rake::TeamCity::MessageFactory.create_suite_finished(description))
          # send_msg(totals)
        end

        def notify_example_started(example)
          name = example.name
          # send_msg(::Rake::TeamCity::MessageFactory.create_test_started(name, ''))
        end

        def notify_example_finished(example)
          name = example.name
          duration = example.duration

          # if stdout_string && !stdout_string.empty?
          #   send_msg(::Rake::TeamCity::MessageFactory.create_test_output_message(name, true, stdout_string))
          # end
          #
          # if stderr_string && !stderr_string.empty?
          #   send_msg(::Rake::TeamCity::MessageFactory.create_test_output_message(name, false, stderr_string))
          # end

          # notify_success or failure or pending

          # send_msg(::Rake::TeamCity::MessageFactory.create_test_finished(name, duration, nil))
        end

        private

        def notify_success(result)

        end

        def notify_failure(result)
          name = result.description
          exception = result.exception
          backtrace = result.exception_backtrace
          # send_msg(::Rake::TeamCity::MessageFactory.create_test_failed(name, exception, backtrace))
        end

        def notify_pending(result)
          name = result.description
          # send_msg(::Rake::TeamCity::MessageFactory.create_test_ignored(name, ''))
        end
      end
    end
  end
end

