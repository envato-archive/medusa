module Medusa #:nodoc: 
  module Messages #:nodoc:

    # Message indicating to the master that this worker is leaving.
    class Died < Medusa::Message
      def handle_by_master(master, worker)
        master.worker_gone(worker)
      end
    end

  end
end
