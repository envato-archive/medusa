require 'rspec/core/formatters/progress_formatter'
module RSpec
  module Core
    module Formatters
      class MedusaFormatter < ProgressFormatter
        def example_passed(example)
          output.puts "RSPECPASSED: #{example.description}"
        end

        def example_pending(example)
          output.puts "RSPECPENDING: #{example.description}"
        end

        def example_failed(example)
          output.puts "RSPECFAILED: #{example.description}"
          dump_failure_info(example)
          output.puts "--ENDRSPECFAILED--"
        end

        # Stifle the post-test summary
        def dump_summary(duration, example, failure, pending)
        end

        # Stifle pending specs
        def dump_pending
        end
      end
    end
  end
end

