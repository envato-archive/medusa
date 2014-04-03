module Medusa #:nodoc: 
  module Messages #:nodoc:
    class RunnerStartupFailure < Medusa::Message
      message_attr :log

      def handle_by_worker(worker, runner)
        worker.send_message_to_master(self)
        worker.runner_gone(runner)
        worker.check_runners_ready
      end

      def handle_by_master(master, worker)
        master.notify! :runner_startup_failure, log
      end

    end
  end
end