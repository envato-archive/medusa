require 'rspec/core/formatters/base_formatter'

module RSpec
  module Core
    module Formatters
      class MedusaFormatter < BaseFormatter

        def initialize(*args)
          super

          @example_path = []
        end

        def self.with_stdout
          old_stdout = $stdout
          @stream = $stdout = StringIO.new
          yield
          $stdout = old_stdout
        end

        def self.stdout_stream
          @stream || StringIO.new
        end

        def example_group_started(example_group)
          super(example_group)

          @example_path.push example_group.description
        end

        def example_group_finished(example_group)
          super(example_group)

          @example_path.pop
        end

        def example_started(example)
          super(example)
          self.class.stdout_stream.string = ""
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
          output.puts Medusa::Messages::ExampleGroupSummary.new(
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
          Medusa::Messages::TestResult.new.tap do |r|
            r.name = "#{@example_path.join(' ')} #{example.description}"
            r.duration = example.execution_result[:run_time]
            r.status = example.execution_result[:status].to_sym
            r.driver = Medusa::Drivers::RspecDriver.name
            r.file = file
            r.location = example.location
            r.stdout = self.class.stdout_stream.string.chomp

            if example.exception
              r.exception = example.exception
            end
          end
        end
      end
    end
  end
end

