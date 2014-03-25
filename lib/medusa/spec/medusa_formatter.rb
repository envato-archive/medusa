require 'rspec/core/formatters/base_formatter'

module RSpec
  module Core
    module Formatters
      class MedusaFormatter < BaseFormatter
        def initialize(output)
          super(output)
        end

        def example_started(example)
          super(example)

          output.puts Medusa::Messages::Runner::ExampleStarted.new(example_name: example.description)
        end

        def example_passed(example)
          super(example)

          results = example_to_json(example)
          file_path = example_file_path(example)
          output.puts Medusa::Messages::Runner::Results.new(output: results, file: file_path)
        end

        def example_pending(example)
          super(example)

          results = example_to_json(example)
          file_path = example_file_path(example)
          output.puts Medusa::Messages::Runner::Results.new(output: results, file: file_path)
        end

        def example_failed(example)
          super(example)

          results = example_to_json(example)
          file_path = example_file_path(example)
          output.puts Medusa::Messages::Runner::Results.new(output: results, file: file_path)
        end

        def dump_summary(duration, example_count, failure_count, pending_count)
          super(duration, example_count, failure_count, pending_count)
          output.puts Medusa::Messages::Runner::ExampleGroupSummary.new(
            file: example_group,
            duration: duration,
            example_count: example_count,
            failure_count: failure_count,
            pending_count: pending_count
          )
        end

        private

        def example_file_path(example)
          example.file_path.gsub(/\.\//, '')
        end

        def example_to_json(example)
          {
            :description => example.description,
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

