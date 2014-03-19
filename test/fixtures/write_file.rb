require File.join(File.dirname(__FILE__), '..', 'test_helper')

class WriteFileTest < Test::Unit::TestCase
  def test_write_a_file
    File.open(File.join(Dir.consistent_tmpdir, 'medusa_test.txt'), 'a') do |f|
      f.write "HYDRA"
    end
  end
end

