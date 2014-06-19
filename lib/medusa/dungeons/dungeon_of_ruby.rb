module Medusa
  module Dungeons
    class DungeonOfRuby
      include DRbUndumped

      FILE = %q{
require 'drb'
$LOAD_PATH.unshift('/Users/elseano/src/medusa/lib')
require 'medusa'

class MedusaInterface
  def exec(code)
    eval(code)
  end

  def quit
    exit(0)
  end
end


fork do
  Medusa.register_driver Medusa::Drivers::RspecDriver.new

  name = ARGV.shift
  uri = ARGV.shift
  location = Pathname.new(__FILE__).dirname.expand_path
  puts "Starting dungeon instance at #{uri}"
  $0 = "[medusa] Dungeon Instance #{location}"
  Medusa.logger = Medusa::Logger.new(location.join('.medusa.log').to_s)
  Medusa.logger.debug("TEST")
  client = Medusa::Dungeons::DungeonOfRuby.new(name, location)
  server = DRb::DRbServer.new(uri, client)
  server.thread.join
end
}

      def self.create(name, location)
        Medusa.logger.tagged(self.class.name).debug("Starting dungeon client")

        contents = FILE
        File.open(location.join(".medusa.rb").to_s, "w") { |f| f.write contents }
        Dir.chdir(location.to_s)

        Medusa.logger.tagged(self.name).debug("ruby #{location.join(".medusa.rb")} drbunix:/#{location.join('medusa-pipe')}")

        Process.spawn "bundle exec ruby #{location.join(".medusa.rb")} \"#{name}\" drbunix:/#{location.join('medusa-pipe')} &> .medusa.log"

        Medusa.logger.tagged(self.name).debug("Done")

        sleep(5)

        return DRb::DRbObject.new(nil, "drbunix:/#{location.join('medusa-pipe')}")
      end

      attr_reader :location, :name

      def initialize(name, location)
        @location = location
        @name = name
        @logger = Medusa.logger.tagged(self.class.name)
      end

      def exec(what)
        @logger.debug what
        eval(what)
      end

      def spawn_minions(number)
        @logger.debug("Spawning #{number} minions...")

        @union = Union.new(self)

        number.times do |minion_name|
          minion = Minion.new(self, minion_name)
          @union.represent(minion)
          @union.wait_for_ready
        end

        @union.provide_training([])

        @union
      end

      def die!
        @union.finished
        exit(0)
      end

      def report(info)
        @logger.debug(info.inspect)
      end

    end
  end
end

