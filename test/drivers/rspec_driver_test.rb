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

  def result_messages
    @messages.select { |m| m.is_a?(Medusa::Messages::Runner::Results) }
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

      assert stream.result_messages.length == 1, "Should only be 1 message, but there was #{stream.result_messages.length}"
    end

    should "run two tests sequentially" do
      stream = BasicMessageStream.new

      driver = Medusa::Drivers::RspecDriver.new(stream)
      driver.execute(simple_test_file)
      driver.execute(simple_test_file)

      assert stream.result_messages.length == 2, "Should only be 2 messages, but there was #{stream.result_messages.length}"
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

      assert stream.result_messages.length == 2, "Should be 2 messages, but there was #{stream.result_messages.length}"
    end

    should "run two tests sequentially" do
      stream = BasicMessageStream.new

      driver = Medusa::Drivers::RspecDriver.new(stream)
      driver.execute(test_file)
      driver.execute(test_file)

      assert stream.result_messages.length == 4, "Should be 4 messages, but there was #{stream.result_messages.length}"
    end
  end

  context "with a spec writing to stdout" do
    def stdout_test_file
      Pathname.new(File.dirname(__FILE__)).join("../fixtures/rspec/simple/stdout_spec.rb")
    end

    should "run a test" do
      stream = BasicMessageStream.new

      driver = Medusa::Drivers::RspecDriver.new(stream)
      driver.execute(stdout_test_file)

      assert stream.result_messages.length == 1, "Should only be 1 message, but there was #{stream.result_messages.length}"
    end

  end

  context "with a failing spec" do
    def failure_test_file
      Pathname.new(File.dirname(__FILE__)).join("../fixtures/rspec/simple/simple_failure_spec.rb")
    end

    should "capture the failure" do
      stream = BasicMessageStream.new

      driver = Medusa::Drivers::RspecDriver.new(stream)
      driver.execute(failure_test_file)

      assert stream.result_messages.length == 1, "Should only be 1 message, but there was #{stream.result_messages.length}"
      assert_equal JSON.parse(stream.result_messages.first.output)['status'], 'failed'
    end

  end

end