module Medusa
  module Blueprints

    # Loads up the spec helper file is it's available.
    class SpecHelper

      class RequireSpecHelperCommand
        def execute(dungeon, reporter)
          spec_helper = dungeon.location.join("spec/spec_helper.rb")

          dungeon.exec "ENV['RAILS_ENV'] = 'test'"

          if spec_helper.exist?
            # Medusa.logger.tagged(self.class.name).info("Requiring #{spec_helper}")
            # dungeon.exec "require '#{spec_helper.to_s}'"
          end

          # spec_helper = dungeon.location.join("config/environment.rb")

          # if spec_helper.exist?
          #   Medusa.logger.tagged(self.class.name).info("Requiring #{spec_helper}")
          #   dungeon.exec "require '#{spec_helper}'"
          # end
        end
      end

      def execute(keeper, dungeon)
        dungeon.build!(RequireSpecHelperCommand.new)
      end

    end
  end
end
