require File.expand_path(File.join(File.dirname(__FILE__), '../test_helper'))
require 'pathname'

class BasicMessageStream
  attr_reader :messages
  def initialize
    @messages = []
  end
  def write(message)
    @messages << message
  end
end

class RSpecDriverTest < Test::Unit::TestCase
  context "with a file to test" do
    def simple_test_file
      Pathname.new(File.dirname(__FILE__)).join("../fixtures/rspec/simple/simple_test_file_spec.rb")
    end

    should "run a test" do
      stream = BasicMessageStream.new

      driver = Medusa::Drivers::RspecDriver.new(stream)
      driver.execute(simple_test_file)

      assert stream.messages.length == 1, "#{stream.messages.length} not the expected size"
    end

    should "run two tests sequentially" do
      stream = BasicMessageStream.new

      driver = Medusa::Drivers::RspecDriver.new(stream)
      driver.execute(simple_test_file)
      driver.execute(simple_test_file)

      assert stream.messages.length == 2, "#{stream.messages.length} not the expected size"
    end
  end

  context "with a file to test inside a complex environment" do
    def test_file
      Pathname.new(File.dirname(__FILE__)).join("../fixtures/rspec/complex/test_file_spec.rb")
    end

    should "run a test" do
      stream = BasicMessageStream.new

      driver = Medusa::Drivers::RspecDriver.new(stream)
      driver.execute(test_file)

      assert stream.messages.length == 2, "#{stream.messages.length} not the expected size"
    end

    should "run two tests sequentially" do
      stream = BasicMessageStream.new

      driver = Medusa::Drivers::RspecDriver.new(stream)
      driver.execute(test_file)
      driver.execute(test_file)

      assert stream.messages.length == 4, "#{stream.messages.length} not the expected size"
    end
  end

end