module Medusa #:nodoc:
  module Listener #:nodoc:
    # Minimal output listener. Outputs all the files at the start
    # of testing and outputs a ./F/E per file. As well as
    # full error output, if any.
    class MinimalOutput < Medusa::Listener::Abstract
      # output a starting message
      def report_all_work_begun(files)
        @output.write "Medusa Testing:\n#{files.inspect}\n"
      end

      # output a finished message
      def report_all_work_completed
        @output.write "\nMedusa Completed\n"

        @error_collection.each do |(what, exception_class, exception_message, exception_backtrace, stdout)|
          @output.write "\n\n"
          @output.write "#{what}\n"
          @output.write "#{exception_class} - #{exception_message}\n"
          @output.write "#{exception_backtrace}\n"
        end

        @output.write("\n\n")
      end

      def report_work_result(result)
        if result.failure? || result.fatal?
          @output.write @errors ? "\033[0;31m" : "\033[0;32m"
          @output.write "F"
          @output.write "\033[0m"
          @error_collection ||= []
          @error_collection << [result.name, result.exception_class, result.exception_message, result.exception_backtrace, result.stdout]
        else
          @output.write "."
        end
      end
    end
  end
end
