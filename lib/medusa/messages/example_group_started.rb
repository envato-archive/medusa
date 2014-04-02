module Medusa #:nodoc:
  module Messages #:nodoc:

    class ExampleGroupStarted < Medusa::Message
      message_attr :group_name

      include WorkerPassthrough

      def handle_by_master(master)
        master.notify! :example_group_started, group_name
      end

    end
  end
end