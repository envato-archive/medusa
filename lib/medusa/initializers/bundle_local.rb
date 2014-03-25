module Medusa
  module Initializers
    class BundleLocal
      def pre_boot(command_stream)
        command_stream.write_raw("bundle --local --path .bundle\n")
        command_stream.read_raw
      end
    end
  end
end