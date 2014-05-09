module Medusa #:nodoc: 
  module Messages #:nodoc:

    class TestResult < Medusa::Message
      message_attr :name
      message_attr :status
      message_attr :duration
      message_attr :exception_message
      message_attr :exception_class
      message_attr :exception_backtrace
      message_attr :file
      message_attr :driver

      def handle_by_worker(worker, runner)
        worker.send_message_to_master(self)
      end

      def handle_by_master(master, worker)
        master.notify! :result_received, self
      end

      def exception=(value)
        if value
          @exception_class = value.class.name
          @exception_message = value.message
          @exception_backtrace = value.backtrace
        else
          @exception_class = @exception_message = @exception_backtrace = nil
        end
      end

      def failure?
        status.to_s == 'failed'
      end

      def fatal?
        status.to_s == 'fatal'
      end

      def status=(value)
        raise ArgumentError, "Invalid status #{value}" unless ["passed", "failed", "fatal"].include?(value.to_s)
        @status = value
      end

      def self.fatal_error(file, exception)
        new.tap do |r|
          r.exception = exception
          r.file = file
          r.status = :fatal
        end
      end

    end
  end
end