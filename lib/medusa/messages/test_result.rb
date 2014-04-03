module Medusa #:nodoc: 
  module Messages #:nodoc:

    class TestResult < Medusa::Message
      message_attr :name, :status, :duration, 
      message_attr :exception_message, :exception_class, :exception_backtrace
      message_attr :file
      message_attr :driver

      def handle_by_worker(worker)
        worker.send_message_to_master(self)
      end

      def handle_by_master(master)
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

    end
  end
end