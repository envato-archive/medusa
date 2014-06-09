module Medusa #:nodoc:
  module Messages #:nodoc:

    class TestResult < Medusa::Message
      message_attr :name
      message_attr :status
      message_attr :duration
      message_attr :exception
      message_attr :file
      message_attr :location
      message_attr :driver
      message_attr :stdout

      def handle_by_worker(worker, runner)
        worker.send_message_to_master(self)
      end

      def handle_by_master(master, worker)
        master.notify! :result_received, self
      end

      def failure?
        status.to_s == 'failed'
      end

      def fatal?
        status.to_s == 'fatal'
      end

      def pending?
        status.to_s == 'pending'
      end

      def success?
        status.to_s == "passed"
      end

      def status=(value)
        raise ArgumentError, "Invalid status #{value}" unless ["pending", "passed", "failed", "fatal"].include?(value.to_s)
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
