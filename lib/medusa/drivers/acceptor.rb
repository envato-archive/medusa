require_relative 'rspec_driver'
require_relative 'forked_rspec_driver'

module Medusa

  def self.remove_registered_drivers!
    Drivers::Acceptor.wipe!    
  end  

  def self.register_driver(driver)
    Drivers::Acceptor.register_driver driver
  end

  module Drivers
    class Acceptor

      def self.wipe!
        @drivers = []
      end

      def self.register_driver(driver)
        drivers << driver
      end

      def self.drivers
        @drivers ||= []
      end

      def self.accept?(file)
        Acceptor.drivers.detect { |driver| driver.accept?(file) }
      end

    end
  end
end
