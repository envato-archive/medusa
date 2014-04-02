module Medusa #:nodoc:
  module Messages #:nodoc:

    class ExampleGroupSummary < Medusa::Message
      message_attr :file
      message_attr :duration
      message_attr :example_count
      message_attr :failure_count
      message_attr :pending_count

      include WorkerPassthrough

      def handle_by_master(master)
        master.notify! :file_summary, master
      end
    end

  end
end