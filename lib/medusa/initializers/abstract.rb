module Medusa
  module Initializers
    class Abstract

      def initialize
      end

      def log(master, worker, string)
        master.initializer_output(worker, Messages::Worker::InitializerMessage.new(:initializer => self.class.name, :output => string))
      end

    end
  end
end