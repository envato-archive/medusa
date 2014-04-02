module Medusa
  module Messages

    # Message telling a runner to start a file
    class RunFile < Medusa::Message
      message_attr :file

      def handle_by_worker(worker)
        runner = worker.allocate_free_runner
        runner.send_message(self)
      end

      def handle_by_runner(runner)
        runner.run_file(file)
      end
    end
  end
end