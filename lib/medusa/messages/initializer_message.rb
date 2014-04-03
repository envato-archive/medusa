module Medusa #:nodoc: 
  module Messages #:nodoc:

    class InitializerMessage < Medusa::Message
      message_attr :output

      def handle(master, worker)
        master.notify! :initializer_output, worker, output
      end
    end

  end
end