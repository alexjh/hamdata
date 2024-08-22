#! /usr/bin/env ruby

require 'open-uri'
require 'json'
require_relative '../../hamdata'

tle_text = URI.open('https://www.amsat.org/tle/dailytle.txt').read

meta_path = File.join(File.dirname(__FILE__), 'meta.json')
metas = JSON.load(File.read(meta_path))

# Split into 3-line chunks
data = tle_text.split("\n").each_slice(3).map do |name, tle1, tle2|
  number = tle2[2..6]
  meta = metas[name]

  # HACK: Fix the drag term for QO-100, so that SatelliteKit on iOS can parse it
  if tle1[54..60] == '00000 0'
    tle1[54..60] = '00000-0'
  end

  result = {
    'name' => name,
    'number' => number,
    'tle' => [tle1, tle2],
  }

  result['meta'] = meta if meta
  result
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
