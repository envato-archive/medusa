require_relative 'rspec_driver'

module Medusa
  module Drivers
    class Acceptor

      class DummyDriver
        def initialize
          @logger = Medusa.logger.tagged(self.class.name)
        end

        def self.accept?(file)
          true
        end

        def execute(file, minion)
          @logger.debug("Doing work on #{file}")
          sleep(rand(5))
          minion.inform_work_result(Messages::TestResult.new(file: file, name: "Test 1"))
          sleep(rand(5))
          minion.inform_work_result(Messages::TestResult.new(file: file, name: "Test 2"))
          sleep(rand(5))
          minion.inform_work_result(Messages::TestResult.new(file: file, name: "Test 3"))
          @logger.debug("Done work on #{file}")
        rescue => ex
          @logger.fatal(ex.to_s)
        end
      end

      # DRIVERS = [RspecDriver]
      DRIVERS = [DummyDriver]

      def self.accept?(file)
        if accepted = DRIVERS.detect { |driver| driver.accept?(file) }
          accepted.new
        else
          nil
        end
      end

    end
  end
end