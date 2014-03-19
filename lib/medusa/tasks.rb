require 'open3'
module Medusa #:nodoc:
  # Medusa Task Common attributes and methods
  class Task
    include Rake::DSL if defined?(Rake::DSL)

    # Name of the task. Default 'medusa'
    attr_accessor :name

    # Command line options
    attr_accessor :options

    # Files to test.
    # You can add files manually via:
    #   t.files << [file1, file2, etc]
    #
    # Or you can use the add_files method
    attr_accessor :files

    # True if you want to see Medusa's message traces
    attr_accessor :verbose

    # Path to the medusa config file.
    # If not set, it will check 'medusa.yml' and 'config/medusa.yml'
    attr_accessor :config

    # Automatically sort files using their historical runtimes.
    # Defaults to true
    # To disable:
    #   t.autosort = false
    attr_accessor :autosort

    # Event listeners. Defaults to the MinimalOutput listener.
    # You can add additional listeners if you'd like. For example,
    # on linux (with notify-send) you can add the notifier listener:
    #   t.listeners << Medusa::Listener::Notifier.new
    attr_accessor :listeners

    # Set to true if you want to run this task only on the local
    # machine with one runner. A "Safe Mode" for some test
    # files that may not play nice with others.
    attr_accessor :serial

    attr_accessor :environment

    # Set to false if you don't want to show the total running time
    attr_accessor :show_time

    # Set to a valid file path if you want to save the output of the runners
    # in a log file
    attr_accessor :runner_log_file

    #
    # Search for the medusa config file
    def find_config_file
      @config ||= 'medusa.yml'
      return @config if File.exists?(@config)
      @config = File.join('config', 'medusa.yml')
      return @config if File.exists?(@config)
      @config = nil
    end

    # Add files to test by passing in a string to be run through Dir.glob.
    # For example:
    #
    #   t.add_files 'test/units/*.rb'
    def add_files(pattern)
      @files += Dir.glob(pattern)
    end

  end

  # Define a test task that uses medusa to test the files.
  #
  #   Medusa::TestTask.new('medusa') do |t|
  #     t.add_files 'test/unit/**/*_test.rb'
  #     t.add_files 'test/functional/**/*_test.rb'
  #     t.add_files 'test/integration/**/*_test.rb'
  #     t.verbose = false # optionally set to true for lots of debug messages
  #     t.autosort = false # disable automatic sorting based on runtime of tests
  #   end
  class TestTask < Medusa::Task

    # Create a new MedusaTestTask
    def initialize(name = :medusa)
      @name = name
      @files = []
      @verbose = false
      @autosort = true
      @serial = false
      @listeners = [Medusa::Listener::ProgressBar.new]
      @show_time = true
      @options = ''

      yield self if block_given?

      # Ensure we override rspec's at_exit
      if defined?(RSpec)
        RSpec::Core::Runner.disable_autorun!
      end

      unless @serial
        @config = find_config_file
      end

      @opts = {
        :verbose => @verbose,
        :autosort => @autosort,
        :files => @files,
        :listeners => @listeners,
        :environment => @environment,
        :runner_log_file => @runner_log_file,
        :options => @options
      }
      if @config
        @opts.merge!(:config => @config)
      else
        @opts.merge!(:workers => [{:type => :local, :runners => 1}])
      end

      define
    end

    private
    # Create the rake task defined by this MedusaTestTask
    def define
      desc "Medusa Tests" + (@name == :medusa ? "" : " for #{@name}")
      task @name do
        if Object.const_defined?('Rails') && Rails.env == 'development'
          $stderr.puts %{WARNING: Rails Environment is "development". Make sure to set it properly (ex: "RAILS_ENV=test rake medusa")}
        end

        start = Time.now if @show_time

        puts '********************'
        puts @options.inspect
        master = Medusa::Master.new(@opts)

        $stdout.puts "\nFinished in #{'%.6f' % (Time.now - start)} seconds." if @show_time

        unless master.failed_files.empty?
          raise "Medusa: Not all tests passes"
        end
      end
    end
  end

  # Define a test task that uses medusa to profile your test files
  #
  #  Medusa::ProfileTask.new('medusa:prof') do |t|
  #    t.add_files 'test/unit/**/*_test.rb'
  #    t.add_files 'test/functional/**/*_test.rb'
  #    t.add_files 'test/integration/**/*_test.rb'
  #    t.generate_html = true # defaults to false
  #    t.generate_text = true # defaults to true
  #  end
  class ProfileTask < Medusa::Task
    # boolean: generate html output from ruby-prof
    attr_accessor :generate_html
    # boolean: generate text output from ruby-prof
    attr_accessor :generate_text

    # Create a new Medusa ProfileTask
    def initialize(name = 'medusa:profile')
      @name = name
      @files = []
      @verbose = false
      @generate_html = false
      @generate_text = true

      yield self if block_given?

      # Ensure we override rspec's at_exit
      require 'medusa/spec/autorun_override'

      @config = find_config_file

      @opts = {
        :verbose => @verbose,
        :files => @files
      }
      define
    end

    private
    # Create the rake task defined by this MedusaTestTask
    def define
      desc "Medusa Test Profile" + (@name == :medusa ? "" : " for #{@name}")
      task @name do
        require 'ruby-prof'
        RubyProf.start

        runner = Medusa::Runner.new(:io => File.new('/dev/null', 'w'))
        @files.each do |file|
          $stdout.write runner.run_file(file)
          $stdout.flush
        end

        $stdout.write "\nTests complete. Generating profiling output\n"
        $stdout.flush

        result = RubyProf.stop

        if @generate_html
          printer = RubyProf::GraphHtmlPrinter.new(result)
          out = File.new("ruby-prof.html", 'w')
          printer.print(out, :min_self => 0.05)
          out.close
          $stdout.write "Profiling data written to [ruby-prof.html]\n"
        end

        if @generate_text
          printer = RubyProf::FlatPrinter.new(result)
          out = File.new("ruby-prof.txt", 'w')
          printer.print(out, :min_self => 0.05)
          out.close
          $stdout.write "Profiling data written to [ruby-prof.txt]\n"
        end
      end
    end
  end

  # Define a sync task that uses medusa to rsync the source tree under test to remote workers.
  #
  # This task is very useful to run before a remote db:reset task to make sure the db/schema.rb
  # file is up to date on the remote workers.
  #
  #   Medusa::SyncTask.new('medusa:sync') do |t|
  #     t.verbose = false # optionally set to true for lots of debug messages
  #   end  
  class SyncTask < Medusa::Task

    # Create a new SyncTestTask
    def initialize(name = :sync)
      @name = name
      @verbose = false

      yield self if block_given?

      @config = find_config_file

      @opts = {
        :verbose => @verbose
      }
      @opts.merge!(:config => @config) if @config

      define
    end

    private
    # Create the rake task defined by this MedusaSyncTask
    def define
      desc "Medusa Tests" + (@name == :medusa ? "" : " for #{@name}")
      task @name do
        Medusa::Sync.sync_many(@opts)
      end
    end
  end

  # Setup a task that will be run across all remote workers
  #   Medusa::RemoteTask.new('db:reset')
  #
  # Then you can run:
  #   rake medusa:remote:db:reset
  class RemoteTask < Medusa::Task
    include Open3
    # Create a new medusa remote task with the given name.
    # The task will be named medusa:remote:<name>
    def initialize(name, command=nil)
      @name = name
      @command = command
      yield self if block_given?
      @config = find_config_file
      if @config
        define
      else
        task "medusa:remote:#{@name}" do ; end
      end
    end

    private
    def define
      desc "Run #{@name} remotely on all workers"
      task "medusa:remote:#{@name}" do
        config = YAML.load_file(@config)
        environment = config.fetch('environment') { 'test' }
        workers = config.fetch('workers') { [] }
        workers = workers.select{|w| w['type'] == 'ssh'}
        @command = "RAILS_ENV=#{environment} rake #{@name}" unless @command

        $stdout.write "==== Medusa Running #{@name} ====\n"
        Thread.abort_on_exception = true
        @listeners = []
        @results = {}
        workers.each do |worker|
          @listeners << Thread.new do
            begin
              @results[worker] = if run_command(worker, @command)
                "==== #{@name} passed on #{worker['connect']} ====\n"
              else
                "==== #{@name} failed on #{worker['connect']} ====\nPlease see above for more details.\n"
              end
            rescue 
              @results[worker] = "==== #{@name} failed for #{worker['connect']} ====\n#{$!.inspect}\n#{$!.backtrace.join("\n")}"
            end
          end
        end
        @listeners.each{|l| l.join}
        $stdout.write "\n==== Medusa Running #{@name} COMPLETE ====\n\n"
        $stdout.write @results.values.join("\n")
      end
    end

    def run_command worker, command
      $stdout.write "==== Medusa Running #{@name} on #{worker['connect']} ====\n"
      ssh_opts = worker.fetch('ssh_opts') { '' }
      writer, reader, error = popen3("ssh -tt #{ssh_opts} #{worker['connect']} ")
      writer.write("cd #{worker['directory']}\n")
      writer.write "echo BEGIN HYDRA\n"
      writer.write(command + "\r")
      writer.write "echo END HYDRA\n"
      writer.write("exit\n")
      writer.close
      ignoring = true
      passed = true
      while line = reader.gets
        line.chomp!
        if line =~ /^rake aborted!$/
          passed = false
        end
        if line =~ /echo END HYDRA$/
          ignoring = true
        end
        $stdout.write "#{worker['connect']}: #{line}\n" unless ignoring
        if line == 'BEGIN HYDRA'
          ignoring = false
        end
      end
      passed
    end
  end

  # A Medusa global task is a task that is run both locally and remotely.
  #
  # For example:
  #
  #   Medusa::GlobalTask.new('db:reset')
  #
  # Allows you to run:
  #
  #   rake medusa:db:reset
  #
  # Then, db:reset will be run locally and on all remote workers. This
  # makes it easy to setup your workers and run tasks all in a row.
  #
  # For example:
  #
  #   rake medusa:db:reset medusa:factories medusa:tests
  #
  # Assuming you setup medusa:db:reset and medusa:db:factories as global
  # tasks and medusa:tests as a Medusa::TestTask for all your tests
  class GlobalTask < Medusa::Task
    def initialize(name)
      @name = name
      define
    end

    private
    def define
      Medusa::RemoteTask.new(@name)
      desc "Run #{@name.to_s} Locally and Remotely across all Workers"
      task "medusa:#{@name.to_s}" => [@name.to_s, "medusa:remote:#{@name.to_s}"]
    end
  end
end
