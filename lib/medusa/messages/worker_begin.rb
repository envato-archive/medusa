module Medusa #:nodoc: 
  module Messages #:nodoc:

    class WorkerBegin < Medusa::Message
      def handle_by_master(master, worker)
        master.notify! :worker_begin, worker
      end
    end

  end
end