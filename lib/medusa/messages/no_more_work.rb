module Medusa
  module Messages

    # Message from the Master indicating that there's no more work available.
    # Sent in response to a file request.
    class NoMoreWork < Medusa::Message

      def handle_by_worker(worker)
        worker.shutdown_idle_runners
      end

    end
  end
end