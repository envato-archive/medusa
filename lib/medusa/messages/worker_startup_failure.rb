module Medusa #:nodoc: 
  module Messages #:nodoc:

    class WorkerStartupFailure < Medusa::Message
      message_attr :log

      def handle_by_master(master, worker)
        master.notify! :worker_startup_failure, worker, self
      end
    end

  end
end