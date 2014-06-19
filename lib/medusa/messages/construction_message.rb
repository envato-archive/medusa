module Medusa #:nodoc: 
  module Messages #:nodoc:

    class ConstructionMessage < Medusa::Message
      message_attr :phase
      message_attr :output
    end

  end
end