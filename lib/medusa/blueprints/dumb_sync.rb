module Medusa
  module Blueprints

    # Basic file synchronisation, copies files from the Keeper over to the Dungeon.
    class DumbSync

      # This command object is copied over to the dungeon and executed within
      # its #build! method. It then either skips installing the file or
      # invokes the FileRetriever to send the file data from the Keeper.
      class InstallFileCommand < Struct.new(:name, :md5, :percent)
        def execute(target, file_provider)
          location = target.location
          file = location.join(name)

          return if File.exist?(file.to_s) && Digest::MD5.hexdigest(IO.read(file)) == md5

          ::Medusa.logger.tagged(self.class.name).debug("Installing file #{name}")
          file_provider.report(Messages::ConstructionMessage.new(phase: "Sync", output: "#{percent.to_i} Updating file #{name}"))

          FileUtils.mkdir_p(location.join(name).dirname.to_s)
          File.open(location.join(name).to_s, "w") { |f| f.write file_provider.get_file(name) }
        end
      end

      # Runs within the Keeper's process (it sent as a reference object to the dungeon)
      # and is invoked from the InstallFileCommand when the file is missing within the
      # dungeon or has been changed.
      class FileRetriever
        include DRbUndumped

        def initialize(reporter)
          @reporter = reporter
        end

        def get_file(filename)
          ::Medusa.logger.tagged(self.class.name).debug("Providing file data for #{filename}")
          pwd = Pathname.new(`pwd`.chomp)
          IO.read(pwd.join(filename))
        end

        def report(message)
          @reporter.report(message)
        end
      end

      def initialize
        @mutex = Mutex.new
        @logger = ::Medusa.logger.tagged(self.class.name)
      end

      # Sends a series of InstallFileCommands over to the dungeon.
      def execute(keeper, dungeon)
        load_file_info

        @logger.debug("Executing on #{dungeon}")
        retriever = FileRetriever.new(keeper)

        @files.each_with_index do |file, index|
          command = InstallFileCommand.new(file[0], file[1], index.to_f * 100 / @files.length)
          dungeon.build!(command, retriever)
        end
      end

      def load_file_info
        if @files.nil?
          @mutex.synchronize do
            @logger.debug("Collating files for synchronization")
            @files ||= begin
              pwd = Pathname.new(`pwd`.chomp)

              Dir.glob(pwd.join("**/*").to_s, File::FNM_DOTMATCH).collect do |file|
                next unless File.file?(file)
                next if file =~ /\.log/
                next if file =~ /\/tmp\//
                next if file =~ /\/\.git\//
                next if File.size(file) > 1_000_000


                [file.sub("#{pwd}/", ""), Digest::MD5.hexdigest(IO.read(file))]
              end.compact
            end
            @logger.info("#{@files.count} files for synchronization")
          end
        end
      end
    end
  end
end
