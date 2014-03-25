module Medusa
  module Drivers
    class Result
      def parse_medusa_formatter_results(json_string)
        results = JSON(json_string)

        @passed = results[:summary][:success_count]
        @failed = results[:summary][:failure_count]
        @pending = results[:summary][:pending_count]

        @test_results = results[:tests]
      end

      def fatal!(message, backtrace)
        @fatal = [message, backtrace]
      end

      def to_s
        puts "Passed: #{@passed}, Failed: #{@failed.length}, Pending: #{@pending.length}, Fatal Error: #{!!@fatal}"
      end
    end
  end
end
