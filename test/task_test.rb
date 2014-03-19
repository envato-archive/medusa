require File.join(File.dirname(__FILE__), 'test_helper')
require 'medusa/tasks'
require 'rake'

class TaskTest < Test::Unit::TestCase
  context "a task" do
    should "execute the command in a remote machine" do
      
      File.delete( "/tmp/new_file" ) if File.exists? "/tmp/new_file"

      Medusa::RemoteTask.new('cat:text_file', 'touch new_file') do |t|
        t.config = "test/fixtures/task_test_config.yml"
      end

      Rake.application['medusa:remote:cat:text_file'].invoke

      assert( File.exists? "/tmp/new_file" )
      
    end
  end
end
