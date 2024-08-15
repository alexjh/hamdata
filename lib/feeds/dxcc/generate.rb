#! /usr/bin/env ruby

require 'open-uri'
require 'json'
require_relative '../../hamdata'

json = URI.open('https://clublog.org/mostwanted.php?api=1').read
data = JSON.parse(json)

output = {
  'updated' => Time.now.utc.iso8601,
  'data' => data.map do |rank, dxcc| 
    { 
      'rank' => rank.to_i,
      'dxcc' => dxcc.to_i
    }
  end
}

Hamdata.open_output_file('dxcc/most_wanted.json') do |f|
  f.puts JSON.pretty_generate(output)
end