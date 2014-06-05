# require_relative 'rspec_driver'

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
          minion.receive_result(file, true)
          sleep(rand(5))
          minion.receive_result(file, true)
          sleep(rand(5))
          minion.receive_result(file, true)
          @logger.debug("Done work on #{file}")
        rescue => ex
          @logger.fatal(ex.to_s)
        end
      end

      # DRIVERS = [RspecDriver]
      DRIVERS = [DummyDriver]

      def self.accept?(file)
        accepted = DRIVERS.detect { |driver| driver.accept?(file) }
        accepted.new
      end

    end
  end
end