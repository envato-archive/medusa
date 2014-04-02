module Medusa #:nodoc:
  # Base message object. Used to pass messages with parameters around
  # via IO objects.
  #   class MyMessage < Medusa::Message
  #     attr_accessor :my_var
  #     def serialize
  #       super(:my_var => @my_var)
  #     end
  #   end
  #   m = MyMessage.new(:my_var => 'my value')
  #   m.my_var
  #     => "my value"
  #   m.serialize
  #     => "{:class=>TestMessage::MyMessage, :my_var=>\"my value\"}"
  #   Medusa::Message.build(eval(@m.serialize)).my_var
  #     => "my value"
  class Message
    # Create a new message. Opts is a hash where the keys
    # are attributes of the message and the values are
    # set to the attribute.
    def initialize(values = {})
      self.class.message_attrs.each do |attr|
        self.send("#{attr}=", values[attr])
      end
    end

    # Build a message from a hash. The hash must contain
    # the :class symbol, which is the class of the message
    # that it will build to.
    def self.build(hash)      
      hash.delete(:class).new(hash)
    end

    def self.deserialize(string)
      build(eval(string))
    end

    # Serialize the message for output on an IO channel.
    # This is really just a string representation of a hash
    # with no newlines. It adds in the class automatically
    def serialize
      data = Hash.new
      self.class.message_attrs.each do |attr|
        data[attr] = send(attr)
      end

      data.merge({:class => self.class}).inspect
    end

    def self.message_attrs
      @message_attrs
    end

    def self.message_attr(name)
      @message_attrs ||= []
      @message_attrs << name

      attr_accessor name
    end
  end
end

# require 'medusa/message/runner_messages'
# require 'medusa/message/worker_messages'
# require 'medusa/message/master_messages'

