require 'rspec/core/formatters/base_formatter'

module RSpec
  module Core
    module Formatters
      class MedusaFormatter < BaseFormatter
        attr_accessor :results

        def initialize(output)
          super(output)
          @results = { :tests => [] }
        end

        def example_passed(example)
          super(example)
          @results[:tests] << example_to_hash(example)
        end

        def example_pending(example)
          super(example)
          @results[:tests] << example_to_hash(example)
        end

        def example_failed(example)
          super(example)
          @results[:tests] << example_to_hash(example)
        end

        def dump_summary(duration, example, failure, pending)
          super(duration, example, failure, pending)

          results[:summary] = {
            :duration => @duration,
            :example_count => @example_count,
            :failure_count => @failure_count,
            :pending_count => @pending_count,
            :success_count => @example_count - @failure_count - @pending_count,
          }
        end

        def start_dump
          output.puts @results.to_json
        end

        private

        def example_to_hash(example)
          if exception_data = example.exception
            exception = {
              :class => exception_data.class.name,
              :message => exception_data.message,
              :backtrace => exception_data.backtrace,
            }
          end

          {
            :description => example.description,
            :full_description => example.full_description,
            :status => example.execution_result[:status].to_sym,
            :file_path => example.metadata[:file_path],
            :line_number  => example.metadata[:line_number],
            :run_time => example.execution_result[:run_time],
            :exception => exception,
          }
        end
      end
    end
  end
end

