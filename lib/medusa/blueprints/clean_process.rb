module Medusa
  module Blueprints
    class CleanDungeon

      class InstallScriptCommand
        def execute(dungeon, reporter)
          File.open(dungeon.location.join(".medusa.rb").to_s, "w") { |f| f.write __DATA__ }
        end
      end


    end
  end
end

__END__

require 'drb'

class MedusaInterface
  def exec(code)
    eval(code)
  end
end

fork do
  uri = ARGV.shift
  location = File.basename(File.dirname(File.expand_path(__FILE__)))
  puts "Opening DRb connection to #{uri}"
  $0 = "[medusa] Dungeon Instance #{location}"
  server = DRb::DRbServer.new(uri, MedusaInterface.new)
  server.thread.join
end