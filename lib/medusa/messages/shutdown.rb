module Medusa
  module Messages

    # Message telling a worker or runner to exit
    class Shutdown < Medusa::Message

      def handle_by_worker(worker)
        worker.terminate!
      end

      def handle_by_runner(runner)
        runner.stop
      end
    end
  end
end