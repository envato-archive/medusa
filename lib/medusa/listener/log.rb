module Medusa #:nodoc:
  module Listener #:nodoc:
    # Output a progress bar as files are completed
    class Log < Medusa::Listener::Abstract

      def initialize(*args)
        @workers = Hash.new
        @mode = :setup
        @worker_failures = []
        @runner_failures = []
        @error_collection = []
        @files_completed = 0
        @test_output = ""
        @errors = false
        @tests_executed = 0
        @fatals = 0
      end


      # Store the total number of files
      def testing_begin(files)
        puts "[testing-begin] files: #{files.size}"
      end

      def worker_startup_failure(worker, log)
        puts "[worker-startup-failure]"
        puts log.join("\n")
      end

      def runner_startup_failure(runner, log)
        puts "[runner-startup-failure]"
        puts log.join("\n")
      end

      def initializer_start(command, worker)
        puts "[initializer-start] command: #{command}"
      end

      def initializer_result(command, worker)
        puts "[initializer-result] command: #{command}"
      end

      def initializer_output(message, worker)
        message.output.to_s.split("\n").each do |line|
          puts "[initializer-output] #{line}"
        end
      end

      def initializer_failure(worker, initializer, result)
        result.output.to_s.split("\n").each do |line|
          puts "[initializer-failure] #{line}"
        end
      end

      def result_received(result)
        puts "[result-received] #{result.status} #{result.name}"
      end

      # Increment completed files count and update bar
      def file_end(file)
      end

      # Break the line
      def testing_end
      end

      private

    end
  end
end

