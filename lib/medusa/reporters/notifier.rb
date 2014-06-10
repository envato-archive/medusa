module Medusa #:nodoc:
  module Reporters #:nodoc:
    # Sends a command to Notifier when the testing has finished
    # http://manpages.ubuntu.com/manpages/gutsy/man1/notify-send.1.html
    class Notifier < Medusa::Reporters::Abstract
      # output a finished notification
      def testing_end
        icon_path = File.join(
          File.dirname(__FILE__), '..', '..', '..',
          'medusa-icon-64x64.png'
        )
        `notify-send -i #{icon_path} "Medusa" "Testing Completed"`
      end
    end
  end
end
