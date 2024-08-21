#! /usr/bin/env ruby

require 'open-uri'
require 'json'
require_relative '../../hamdata'

tle_text = URI.open('https://www.amsat.org/tle/dailytle.txt').read

meta_path = File.join(File.dirname(__FILE__), 'meta.json')
meta = JSON.load(File.read(meta_path))

# Split into 3-line chunks
data = tle_text.split("\n").each_slice(3).map do |name, tle1, tle2|
  number = tle2[2..6].to_i
  meta = meta[name] || {}

  {
    'name' => name,
    'tqsl_name' => name,
    'number' => number,
    'tle' => [tle1, tle2],
    'heard' => false,
    'aliases' => [],
    'links' => [],
    'transponders' => [],
    'status' => 'unknown'
}.merge(meta)
end


output = {
  'updated' => Time.now.utc.iso8601,
  'data' => data
}

Hamdata.open_output_file('amsat/satellites.json') do |f|
  f.puts JSON.generate(output)
end

Hamdata.open_output_file('amsat/dailytle.txt') do |f|
  f.puts tle_text
end
