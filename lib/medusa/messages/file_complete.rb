module Medusa #:nodoc:
  module Messages #:nodoc:
    class FileComplete < Medusa::Message
      message_attr :file

      def handle_by_worker(worker, runner)
        runner.free = true
        worker.send_to_master(self)
      end

      def handle_by_master(master)
        master.file_complete(self)
      end

    end

  end
end