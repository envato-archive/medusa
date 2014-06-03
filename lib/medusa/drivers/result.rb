module Medusa
  module Drivers
    class Result
      attr_accessor :description, :status, :run_time, :duration
      attr_reader :exception_message, :exception_class, :exception_backtrace

      def exception=(value)
        @exception_class = value.class.name
        @exception_message = value.message
        @exception_backtrace = value.backtrace
      end

      def [](value)
        self.send(value) if self.respond_to?(:value)
      end

      def success?
        status == :success
      end

      def failure?
        status == :failed
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

