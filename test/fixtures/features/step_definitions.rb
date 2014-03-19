Given /^a target file$/ do
  @target_file = File.expand_path(File.join(Dir.consistent_tmpdir, 'medusa_test.txt'))
end

Given /^an alternate target file$/ do
  @target_file = File.expand_path(File.join(Dir.consistent_tmpdir, 'alternate_medusa_test.txt'))
end

When /^I write "([^\"]*)" to the file$/ do |text|
  f = File.new(@target_file, 'w')
  f.write text
  f.flush
  f.close
end

Then /^"([^\"]*)" should be written in the file$/ do |text|
  f = File.new(@target_file, 'r')
  raise 'Did not write to file' unless text == f.read
  f.close
end

