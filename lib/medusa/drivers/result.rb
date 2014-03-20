module Medusa
  module Drivers
    class Result
      def initialize
        @passed = 0
        @failed = []
        @pending = []
      end

      def inc_passed!
        @passed += 1
      end

      def inc_failed!(name, output)
        @failed << [name, output]
      end

      def inc_pending!(name)
        @pending << name
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