module Medusa #:nodoc: 
  module Messages #:nodoc:

    # Message indicating that runner is ready for a file.
    class RequestFile < Medusa::Message

      include WorkerPassthrough

      def handle_by_master(master, worker) #:nodoc:
        master.send_file(worker)
      end

    end
  end
end