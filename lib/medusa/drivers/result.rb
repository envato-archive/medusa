module Medusa
  module Drivers
    class Result
      attr_accessor :description, :status, :run_time, :exception, :exception_backtrace, :duration

      def self.parse_json(json_string)
        attributes = JSON(json_string)
        Result.new(attributes)
      end

      def initialize(attributes)
        @description = attributes['description']
        @status = attributes['status'].to_sym
        @run_time = attributes['run_time']
        @exception = attributes['exception']
        @exception_backtrace = attributes['exception_backtrace']
        @duration = attributes['duration']
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

