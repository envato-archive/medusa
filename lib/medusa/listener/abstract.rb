module Medusa #:nodoc:
  module Listener #:nodoc:
    # Abstract listener that implements all the events
    # but does nothing.
    class Abstract
      # Create a new listener.
      #
      # Output: The IO object for outputting any information.
      # Defaults to STDOUT, but you could pass a file in, or STDERR
      def initialize(output = $stdout)
        @output = output
      end

      def initializer_start(command, worker)
      end

      def initializer_result(command, worker)
      end

      def initializer_failure(worker, initializer, result)
      end

      def initializer_output(message, worker)
      end


      # Fired when testing has started
      def testing_begin(files)
      end

      # Fired when testing finishes, after the workers shutdown
      def testing_end
      end

      # Fired when a worker cannot startup due to an error.
      def worker_startup_failure(worker, log)
      end

      # Fired when a runner cannot startup due to an error.
      def runner_startup_failure(worker, log)
      end

      # Fired after runner processes have been started
      def worker_begin(worker)
      end

      # Fired before shutting down the worker
      def worker_end(worker)
      end

      # Fired when a file is started
      def file_begin(file)
      end

      # Fired when a file is finished
      def file_end(file)
      end

      def file_summary(summary)
      end

      def example_group_started(group_name)
      end

      def example_group_finished(group_name)
      end

      def example_begin(example_name)
      end

      # Fired every time we receive a result from a runner.
      def result_received(file, result)
      end
    end
  end
end
