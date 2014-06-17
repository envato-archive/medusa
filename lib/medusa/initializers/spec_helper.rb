module Medusa
  module Initializers

    # Loads up the spec helper file is it's available.
    class SpecHelper

      class RequireSpecHelperCommand
        def execute(dungeon, reporter)
          Dir.chdir(dungeon.location.to_s)
          spec_helper = dungeon.location.join("spec/spec_helper.rb")

          if spec_helper.exist?
            load spec_helper.to_s
          end
        end
      end

      def execute(keeper, dungeon)
        dungeon.build!(RequireSpecHelperCommand.new)
      end

    end
  end
end
