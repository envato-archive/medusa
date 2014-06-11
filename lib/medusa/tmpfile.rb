require 'tmpdir'
require 'fileutils'
require 'pathname'

module Medusa
  def self.tmpfile(name = nil)
    FileUtils.mkdir_p(File.join(Dir.tmpdir, 'medusa'))

    tmpfile = nil

    while tmpfile.nil? || File.exist?(tmpfile.to_s)
      filename = 10.times.collect { ('a'.ord + rand(25)).chr }.join
      filename = name + "-" + filename if name
      tmpfile = Pathname.new(Dir.tmpdir.to_s).join("medusa", filename)
    end

    return tmpfile
  end
end