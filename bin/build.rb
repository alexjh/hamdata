#! /usr/bin/env ruby

require_relative '../lib/hamdata'
require 'json'

# list lib/feeds/* directories
FEED_DIRS = Dir.glob('lib/feeds/*').select { |f| File.directory? f }

Hamdata.clear_site_dir

configs = FEED_DIRS.map do |feed_dir|
  print "Processing #{feed_dir}... "
  Hamdata.generate(feed_dir)
  puts "done."

  Hamdata.read_config(feed_dir)
end

print "Generating index.html... "
Hamdata.generate_index(configs)
puts "done."
