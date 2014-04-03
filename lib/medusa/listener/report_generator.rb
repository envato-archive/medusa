module Medusa #:nodoc:
  module Listener #:nodoc:
    # Output a textual report at the end of testing
    class ReportGenerator < Medusa::Listener::Abstract
      # Initialize a new report
      def testing_begin(files)
        @report = { }
      end

      # Log the start time of a file
      def file_begin(file)
        @report ||= {}
        @report[file] ||= { }
        @report[file]['start'] ||= Time.now.to_f
        @report[file]['success'] ||= 0
        @report[file]['failure'] ||= 0
      end

      def result_received(result)
        file_begin(result.file) # initialize just in case.

        if result.failure? || result.fatal?
          @report[result.file]['failure'] += 1
        else
          @report[result.file]['success'] += 1
        end
      end


      # Log the end time of a file and compute the file's testing
      # duration
      def file_end(file)
        file_begin(file) # initialize just in case.

        @report[file]['end'] = Time.now.to_f
        @report[file]['duration'] = @report[file]['end'] - @report[file]['start']
        @report[file]['all_tests_passed_last_run'] = @report[file]['failure'] == 0
      end

      # output the report
      def testing_end
        YAML.dump(@report, @output)
        @output.close
      end
    end
  end
end


