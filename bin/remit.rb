#!/usr/bin/env ruby18

$: << File.dirname(__FILE__) + '/..' 

require 'yaml'
require 'lib/remit/command'

if File.basename($0) =~ /^remit/ 
  TIMER_FILE = ENV['REMIT_TIMER_FILE'] || ENV['HOME'] + '/.remit_timers.yml'

  r = Remit::Command.new(*ARGV)
  r.timers += begin
                YAML::load_file TIMER_FILE
              rescue Errno::ENOENT
                []
              end
  r.run

  begin
    File.open(TIMER_FILE, 'w') { |f| f.write YAML.dump(r.timers) }
  rescue
    puts "!!"
    puts "!! ERROR: could not write timers to file (#{TIMER_FILE}), dumping to stdout."
    puts "!!"
    puts YAML.dump(r.timers)
    exit 1
  end
end
