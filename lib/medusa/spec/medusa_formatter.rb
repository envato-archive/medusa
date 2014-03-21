require 'rspec/core/formatters/base_formatter'

module RSpec
  module Core
    module Formatters
      class MedusaFormatter < BaseFormatter
        def initialize(output)
          super(output)
        end

        def example_passed(example)
          super(example)
          output.puts example_to_hash(example)
        end

        def example_pending(example)
          super(example)
          output.puts example_to_hash(example)
        end

        def example_failed(example)
          super(example)
          output.puts example_to_hash(example)
        end

        private

        def example_to_hash(example)
          {
            :description => example.description,
            :status => example.execution_result[:status],
            :run_time => example.execution_result[:run_time],
            :exception => example.exception.try(:message),
            :exception_backtrace => example.exception.try(:backtrace),
          }
        end
      end
    end
  end
end

