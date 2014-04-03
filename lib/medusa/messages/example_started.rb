module Medusa #:nodoc:
  module Messages #:nodoc:

    # Message for when Runner starts a specific example
    class ExampleStarted < Medusa::Message
      message_attr :example_name

      include WorkerPassthrough

      def handle_by_master(master, worker)
        master.notify! :example_started, example_name
      end
    end

  end
end