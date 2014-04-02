module Medusa #:nodoc: 
  module Messages #:nodoc:
    class RunnerStartupFailure < Medusa::Message
      message_attr :log

      include WorkerPassthrough

      def handle_by_master(master, worker)
        master.notify! :runner_startup_failure, log
      end

    end
  end
end