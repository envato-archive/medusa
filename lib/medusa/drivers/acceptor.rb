module Medusa
  module Drivers
    class Acceptor

      DRIVERS = [RspecDriver]

      def self.accept?(file)
        DRIVERS.any? { |driver| driver.accept?(file) }
      end

    end
  end
end