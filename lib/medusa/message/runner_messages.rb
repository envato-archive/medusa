module Medusa #:nodoc:
  module Messages #:nodoc:
    module Runner #:nodoc:
      # Message indicating that a Runner needs a file to run
      class RequestFile < Medusa::Message
        def handle(worker, runner) #:nodoc:
          worker.request_file(self, runner)
        end
      end

      # Message for when Runner starts a specific example
      class ExampleStarted < Medusa::Message
        attr_accessor :example_name

        def handle(worker, runner)
          worker.example_started(self, runner)
        end

        def serialize
          super(example_name: @example_name)
        end
      end

      class ExampleGroupSummary < Medusa::Message
        attr_accessor :file
        attr_accessor :duration
        attr_accessor :example_count
        attr_accessor :failure_count
        attr_accessor :pending_count

        def handle(worker, runner)
          worker.example_group_summary(self, runner)
        end

        def serialize
          super(
            :file => @file,
            :duration => @duration,
            :example_count => @example_count,
            :failure_count => @failure_count,
            :pending_count => @pending_count
          )
        end
      end

      # Message for the Runner to respond with its results
      class Results < Medusa::Message
        # The output from running the test
        attr_accessor :output, :file

        def serialize
          super(output: @output, file: @file)
        end

        def handle(worker, runner) #:nodoc:
          worker.relay_results(self, runner)
        end

        def self.fatal_error(file, exception)
          new(file: file, output: { description: "Fatal Error", status: "fatal", file_path: file, exception: {
              :class => exception.class.name,
              :message => exception.message,
              :backtrace => exception.backtrace,
            }
          }.to_json)
        end
      end

      class FileComplete < Medusa::Message
        attr_accessor :file

        def handle(worker, runner)
          worker.file_complete(self, runner)
        end

        def serialize #:nodoc:
          super(:file => @file)
        end
      end

      # Message a runner sends to a worker to verify the connection
      class Ping < Medusa::Message
        def handle(worker, runner) #:nodoc:
          # We don't do anything to handle a ping. It's just to test
          # the connectivity of the IO
        end
      end

      # The runner forks to run rspec messages
      # so that specs don't get rerun. It uses
      # this message to report the results. See
      # Runner::run_rspec_file.
      class RSpecResult < Medusa::Message
        # the output of the spec
        attr_accessor :output
        def serialize #:nodoc:
          super(:output => @output)
        end
      end
    end
  end
end
