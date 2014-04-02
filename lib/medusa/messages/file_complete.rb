module Medusa #:nodoc:
  module Messages #:nodoc:
    class FileComplete < Medusa::Message
      message_attr :file

      include WorkerPassthrough

      def handle_by_master(master)
        master.file_complete(self)
      end

    end

  end
end