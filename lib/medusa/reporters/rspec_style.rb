module Medusa #:nodoc:
  module Reporters #:nodoc:
    # Minimal output reporter. Outputs all the files at the start
    # of testing and outputs a ./F/E per file. As well as
    # full error output, if any.
    class RSpecStyle < Medusa::Reporters::Abstract

      def initialize(*args)
        super
        @failures = []
      end

      def report_construction_information(message)
        @output.write("#{message.phase} - #{message.output}\r")
      end

      # output a starting message
      def report_all_work_begun(files)
        @output.write "Medusa - testing #{files.length} file(s)...\n"
      end

      def report_all_work_completed
        @output.write "\nMedusa - Completed\n"

        @failures.each_with_index do |failure, index|
          @output.write("  #{index + 1}) #{failure.name}\n")
          @output.write("     ")

          if failure.exception
            @output.puts(read_failed_line(failure.exception, failure.file).strip)

            @output.write("     #{failure.exception.class_name}:\n")
            failure.exception.message.to_s.split("\n").each do |line|
              @output.puts("       #{line}")
            end

            format_backtrace(failure.exception.backtrace, failure.file).each do |line|
              @output.puts("       #{line}")
            end
          end

          @output.puts("\n")
        end
      end

      def report_work_result(result)
        if result.failure?
          @output.write("F")
          @failures << result
        elsif result.fatal?
          @output.write("E")
          @failures << result
        elsif result.pending?
          @output.write("*")
        else
          @output.write(".")
        end
      end

      private

      def format_backtrace(backtrace, file)
        return [] unless backtrace

        # return [file] + backtrace

        last_index = 0
        backtrace.each_with_index do |line, index|
          last_index = index if line.include?(file)
        end

        backtrace[0, last_index + 1].compact
      end

      def find_failed_line(backtrace, path)
        path = File.expand_path(path)
        backtrace.detect { |line|
          match = line.match(/(.+?):(\d+)(|:\d+)/)
          match && match[1].downcase == path.downcase
        }
      end

      def read_failed_line(exception, file_path)
        unless matching_line = find_failed_line(exception.backtrace, file_path)
          return "Unable to find matching line from backtrace"
        end

        file_path, line_number = matching_line.match(/(.+?):(\d+)(|:\d+)/)[1..2]

        if File.exist?(file_path)
          File.readlines(file_path)[line_number.to_i - 1] ||
            "Unable to find matching line in #{file_path}"
        else
          "Unable to find #{file_path} to read failed line"
        end
      rescue SecurityError
        "Unable to read failed line"
      end

    end
  end
end
