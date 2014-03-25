module Medusa #:nodoc: 
  module Messages #:nodoc:
    module Worker #:nodoc:
      # Message indicating that a worker needs a file to delegate to a runner
      class RequestFile < Medusa::Message
        def handle(master, worker) #:nodoc:
          master.send_file(worker)
        end
      end

      class WorkerBegin < Medusa::Message
        def handle(master, worker)
          master.worker_begin(worker)
        end
      end

      class WorkerStartupFailure < Medusa::Message
        attr_accessor :log

        def serialize #:nodoc:
          super(:log => @log)
        end        

        def handle(master, worker)
          master.worker_startup_failure(self, worker)
          raise IOError, "Worker failed to startup"
        end
      end

      class RunnerStartupFailure < Medusa::Message
        attr_accessor :log

        def serialize #:nodoc:
          super(:log => @log)
        end        

        def handle(master, worker)
          master.runner_startup_failure(self, worker)
        end
      end

      class FileComplete < Medusa::Message
        attr_accessor :file

        def handle(master, worker)
          master.file_complete(self, worker)
        end

        def serialize #:nodoc:
          super(:file => @file)
        end
      end

      # Message telling the Runner to run a file
      class RunFile < Medusa::Message
        # The file that should be run
        attr_accessor :file
        def serialize #:nodoc:
          super(:file => @file)
        end
        def handle(runner) #:nodoc:
          runner.run_file(@file)
        end
      end

      # Message to tell the Runner to shut down
      class Shutdown < Medusa::Message
        def handle(runner) #:nodoc:
          runner.stop
        end
      end

      # Message relaying the results of a worker up to the master
      class Results < Medusa::Messages::Runner::Results
        def handle(master, worker) #:nodoc:
          master.process_results(worker, self)
        end
      end

      # Message a worker sends to a master to verify the connection
      class Ping < Medusa::Message
        def handle(master, worker) #:nodoc:
          # We don't do anything to handle a ping. It's just to test
          # the connectivity of the IO
        end
      end
    end
  end
end
