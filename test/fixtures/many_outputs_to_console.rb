#!/usr/bin/env ruby

10000.times do 
  $stdout.write "A non-medusa message...\n"
  $stdout.flush
end

$stdout.write "{:class=>Medusa::Messages::TestMessage, :text=>\"My message\"}\n"
$stdout.flush
