module Medusa #:nodoc: 
  module Messages #:nodoc:

    class InitializerMessage < Medusa::Message
      message_attr :initializer
      message_attr :output

      def handle_by_master(master, worker)
        master.notify! :initializer_output, self, worker
      end
    end

  end
end