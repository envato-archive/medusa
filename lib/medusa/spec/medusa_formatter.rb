require 'rspec/core/formatters/base_formatter'

module RSpec
  module Core
    module Formatters
      class MedusaFormatter < BaseFormatter
        def example_group_started(example_group)
          super(example_group)

          file_path = example_group_file_path(example_group)
          output.puts Medusa::Messages::Runner::ExampleGroupStarted.new(group_name: example_group.description, file: file_path)
        end

        def example_group_finished(example_group)
          super(example_group)

          file_path = example_group_file_path(example_group)
          output.puts Medusa::Messages::Runner::ExampleGroupFinished.new(group_name: example_group.description, file: file_path)
        end

        def example_started(example)
          super(example)

          file_path = example_group_file_path(example.example_group)
          output.puts Medusa::Messages::Runner::ExampleStarted.new(example_name: example.description, file: file_path)
        end

        def example_passed(example)
          super(example)

          results = example_to_json(example)
          file_path = example_group_file_path(example.example_group)
          output.puts Medusa::Messages::Runner::Results.new(output: results, file: file_path)
        end

        def example_pending(example)
          super(example)

          results = example_to_json(example)
          file_path = example_group_file_path(example.example_group)
          output.puts Medusa::Messages::Runner::Results.new(output: results, file: file_path)
        end

        def example_failed(example)
          super(example)

          results = example_to_json(example)
          file_path = example_group_file_path(example.example_group)
          output.puts Medusa::Messages::Runner::Results.new(output: results, file: file_path)
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

        def example_to_json(example)
          {
            :description => example.description,
            :duration => example.execution_result[:run_time],
            :status => example.execution_result[:status].to_sym,
            :run_time => example.execution_result[:run_time],
            :exception => example.exception.try(:message),
            :exception_backtrace => example.exception.try(:backtrace),
          }.to_json
        end
      end
    end
  end
end

