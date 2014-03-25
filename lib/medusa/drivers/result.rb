module Medusa
  module Drivers
    class Result
      attr_accessor :description, :status, :run_time, :exception, :exception_backtrace

      def initialize(attributes)
        @description = attributes[:description]
        @status = attributes[:status].to_sym
        @run_time = attributes[:run_time]
        @exception = attributes[:exception]
        @exception_backtrace = attributes[:exception_backtrace]
      end

      def success?
        status == :success
      end

      def failure?
        status == :failure
      end

      def pending?
        status == :pending
      end

      def fatal?
        status == :fatal
      end
    end
  end
end
