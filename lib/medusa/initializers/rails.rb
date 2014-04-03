module Medusa
  module Initializers
    class Rails < Abstract

      def run(connection, master, worker)
        connection.exec("echo 'Medusa::Initializers::Rails.bootstrap_worker(self)' > medusa_worker_init.rb")
        connection.exec("echo 'Medusa::Initializers::Rails.bootstrap_runner(self)' > medusa_runner_init.rb")

        return Result.success
      end

      # This is run within the worker instance.
      def self.bootstrap_worker(worker)
        Dir["medusa/initializers/worker/*.rb"].sort.each do |init_script|
          run_init_script(init_script, worker)
        end
      end

      # This is run within the runner instance.
      def self.bootstrap_runner(runner)
        Dir["medusa/initializers/runner/*.rb"].sort.each do |init_script|
          run_init_script(init_script, runner)
        end
      end

      def self.run_init_script(script, executor)
        class_name = executor.class.name.split("::").last
        class_name += File.basename(script).sub(".rb", "").gsub(/^([a-z])|_([a-z])/) { |x| x.upcase }.gsub("_", "")

        load(script)

        class_object = begin
          eval(class_name, binding, script)
        rescue NameError
          raise "#{class_name} not found in #{script}"
        end

        instance = class_object.new(executor)
        result = instance.run_initializer
        handle_result(instance, executor)
      end

      def self.handle_result(result, executor)
        return if result.ok?

        if executor.is_a?(::Medusa::Worker)
          executor.io.send_message(Messages::Worker::WorkerStartupFailure.new(:log => result.error))
          raise "Initialization Failed"
        elsif executor.is_a?(::Medusa::Runner)
          executor.io.send_message(Messages::Worker::RunnerStartupFailure.new(:log => result.error))
          raise "Initialization Failed"
        end
      end

    end
  end
end