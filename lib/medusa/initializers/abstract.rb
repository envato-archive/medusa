module Medusa
  module Initializers
    class Abstract

      attr_reader :master, :worker

      def initialize(master, worker)
        @master = master
        @worker = worker
      end

    end
  end
end