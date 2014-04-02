module Medusa
  module Messages

    # Message from the Master indicating that there's no more work available.
    # Sent in response to a file request.
    class NoMoreWork < Medusa::Message

      def handle_by_worker(worker)
        while runner = worker.lock_runner
          runner.send_message(Shutdown.new)
        end
      end

    end
  end
end