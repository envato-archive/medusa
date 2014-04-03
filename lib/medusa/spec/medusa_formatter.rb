require 'rspec/core/formatters/base_formatter'

module RSpec
  module Core
    module Formatters
      class MedusaFormatter < BaseFormatter
        def example_group_started(example_group)
          super(example_group)
          output.puts Medusa::Messages::Runner::ExampleGroupStarted.new(group_name: example_group.description)
        end

        def example_group_finished(example_group)
          super(example_group)
          output.puts Medusa::Messages::Runner::ExampleGroupFinished.new(group_name: example_group.description)
        end

        def example_started(example)
          super(example)
          output.puts Medusa::Messages::Runner::ExampleStarted.new(example_name: example.description)
        end

        def example_passed(example)
          super(example)

          file_path = example_group_file_path(example.example_group)
          output.puts example_to_result(example, file_path)
        end

        def example_pending(example)
          super(example)

          file_path = example_group_file_path(example.example_group)
          output.puts example_to_result(example, file_path)
        end

        def example_failed(example)
          super(example)

          file_path = example_group_file_path(example.example_group)
          output.puts example_to_result(example, file_path)
        end

        def dump_summary(duration, example_count, failure_count, pending_count)
          super(duration, example_count, failure_count, pending_count)
          output.puts Medusa::Messages::Runner::ExampleGroupSummary.new(
            file: example_group_file_path(example_group),
            duration: duration,
            example_count: example_count,
            failure_count: failure_count,
            pending_count: pending_count
          )
        end

        private

        def example_group_file_path(example_group)
          example_group.file_path.gsub(/\.\//, '') rescue "<file not available>"
        end

        def example_to_result(example, file)
          Medusa::Messages::Runner::TestResult.new.tap do |r|
            r.description = example.description
            r.duration = example.execution_result[:run_time]
            r.status = example.execution_result[:status].to_sym
            r.driver = Drivers::RSpecDriver.name
            r.file = file

            if example.exception
              r.exception = example.exception
            end
          end
        end
      end
    end
  end
end

