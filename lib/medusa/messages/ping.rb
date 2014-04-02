module Medusa #:nodoc:
  module Messages #:nodoc:

    # Message a runner sends to a worker to verify the connection
    class Ping < Medusa::Message
      def handle(worker, runner) #:nodoc:
      end
    end
    
  end
end
