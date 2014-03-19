require 'rspec'
require 'medusa/tmpdir'
context "file writing" do
  it "writes to a file" do
    File.open(File.join(Dir.consistent_tmpdir, 'medusa_test.txt'), 'a') do |f|
      f.write "HYDRA"
    end
  end
end
