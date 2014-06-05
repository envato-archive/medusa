module Medusa
  module Listener

    # Output a progress bar as files are completed
    class ProgressBar < Medusa::Listener::Abstract
      # Store the total number of files
      def testing_begin(files)
        @total_files = files.size
        @files_completed = 0
        @tests_executed = 0
        @fatals = 0
        @test_output = ""
        @errors = false
        render_progress_bar
      end

      # Increment completed files count and update bar
      def file_complete(file)
        @files_completed += 1
        render_progress_bar
      end

      # Break the line
      def testing_end
        render_progress_bar
        @output.write "\n"
      end

      def receive_result(file, result)
        if result.failure? || result.fatal?
          @errors = true
          @error_collection ||= []
          @error_collection << [result.name, result.exception_class, result.exception_message, result.exception_backtrace, result.stdout]
        end

        @tests_executed += 1
        @fatals += 1 if result.fatal?
        
        render_progress_bar
      end

      private

      def render_progress_bar
        width = 30
        complete = ((@files_completed.to_f / @total_files.to_f) * width).to_i
        @output.write "\r" # move to beginning
        @output.write 'Hydra Testing ['
        @output.write @errors ? "\033[0;31m" : "\033[0;32m"
        complete.times{@output.write '#'}
        @output.write '>'
        (width-complete).times{@output.write ' '}
        @output.write "\033[0m"
        @output.write "] #{@files_completed}/#{@total_files} - #{@tests_executed} tests"
        @output.flush
      end
    end
  end
end
