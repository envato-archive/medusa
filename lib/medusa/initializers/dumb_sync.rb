module Medusa
  class DumbSync
    def execute!(keepers)
      pwd = Pathname.new(`pwd`.chomp)

      Dir.glob(pwd.join("**/*").to_s).each do |file|
        next unless File.file?(file)
        keepers.each do |keeper|
          keeper.write_file!(file.sub("#{pwd}/", ""), IO.read(file))
        end
      end
    end
  end
end