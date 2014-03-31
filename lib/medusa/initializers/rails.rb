module Medusa
  module Initializers
    class Rails < Abstract

      def run(connection, master, worker)
        connection.exec("echo 'Medusa::Initializers::Rails.bootstrap_worker' > medusa_worker_init.rb")
        connection.exec("echo 'Medusa::Initializers::Rails.bootstrap_runner' > medusa_runner_init.rb")
      end

      # This is run within the worker instance.
      def self.bootstrap_worker
        
      end

      # This is run within the runner instance.
      def self.bootstrap_runner
        
      end

    end
  end
end