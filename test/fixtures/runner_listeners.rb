module MedusaExtension
  module RunnerListener
    class RunnerBeginTest < Medusa::RunnerListener::Abstract
      # Fired by the runner just before requesting the first file
      def runner_begin( runner )
        FileUtils.touch File.expand_path(File.join(Dir.consistent_tmpdir, 'alternate_medusa_test.txt'))
      end
    end

    class RunnerEndTest < Medusa::RunnerListener::Abstract
      # Fired by the runner just before requesting the first file
      def runner_begin( runner )
        FileUtils.touch File.expand_path(File.join(Dir.consistent_tmpdir, 'runner_began_flag')) #used to know when the runner is ready
      end
      # Fired by the runner just after stoping
      def runner_end( runner )
        # NOTE: do not use trace here
        #runner.trace "Ending runner"
        FileUtils.touch File.expand_path(File.join(Dir.consistent_tmpdir, 'alternate_medusa_test.txt'))
      end
    end
  end
end
