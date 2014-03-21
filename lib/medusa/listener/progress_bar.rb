module Medusa #:nodoc:
  module Listener #:nodoc:
    # Output a progress bar as files are completed
    class ProgressBar < Medusa::Listener::Abstract
      # Store the total number of files
      def testing_begin(files)
        @total_files = files.size
        @files_completed = 0
        @test_output = ""
        @errors = false
        @tests_executed = 0
        @fatals = 0
        @error_collection = []


        @files = files.dup

        render_progress_bar
      end

      def result_received(file, result)
        if result['status'] == 'failure' || result['status'] == 'fatal'
          @errors = true
          @error_collection << [result['description'], result['file_path'], result['line_number'], result['exception']]
        end

        @tests_executed += 1
        @fatals += 1 if result['status'] == 'fatal'
        render_progress_bar
      end

      # Increment completed files count and update bar
      def file_end(file)
        @files_completed += 1
        @files.delete(file)
        render_progress_bar
      end

      # Break the line
      def testing_end
        render_progress_bar
        @output.write "\n"
        render_errors
      end

      private

      def render_errors
        @error_collection.each do |(name, file, line, error)|
          @output.write "#{name}\n"
          @output.write "#{file}:#{line}\n"
          @output.write "#{error['class']} - #{error['message']}\n"
          @output.write error['backtrace'].join("\n")
          @output.write "\n\n"
        end
      end

      def render_progress_bar
        width = 30
        complete = ((@files_completed.to_f / @total_files.to_f) * width).to_i
        @output.write "\r" # move to beginning
        @output.write 'Medusa Testing ['
        @output.write @errors ? "\033[0;31m" : "\033[0;32m"
        complete.times{@output.write '#'}
        @output.write '>'
        (width-complete).times{@output.write ' '}
        @output.write "\033[0m"
        @output.write "] #{@files_completed}/#{@total_files} - #{@tests_executed} tests completed, #{@fatals} fatals."
        @output.flush
      end
    end
  end
end

