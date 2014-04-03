module Medusa #:nodoc:
  module Messages #:nodoc:

    # Message for the Runner to respond with its results
    class Result < Medusa::Message
      message_attr :output
      message_attr :file
      message_attr :result

      include WorkerPassthrough

      def handle_by_master(master) #:nodoc:
        master.process_results(self)
      end
    end
  end
end