#!/usr/bin/env ruby

require "net/http"

HOST = $0[/_(.+)_/,1] ? $0[/_(.+)_/,1] : "localhost"

if %w[traffic connections].include?($0[/_([^_]+)$/,1])
  TYPE = $0[/_([^_]+)$/,1]
else
  puts "wrong parameter: #{$0[/_([^_]+)$/,1]}. should be 'traffic' or 'connections'"
  exit -1
end

if ARGV[0] == "config"
  puts "graph_category Cherokee"
  puts "graph_title #{TYPE.capitalize} for #{HOST}"
  puts "graph_vlabel #{TYPE}"
  if TYPE == "traffic"
    puts "tx.label tx"
    puts "tx.type COUNTER"
    puts "rx.label rx"
    puts "rx.type COUNTER"
  elsif TYPE == "connections"
    puts "number.label number"
    puts "active.label active"
    puts "reusable.label reusable"
  end
else
  begin
    url = URI.parse("http://#{HOST}")
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.get("/status/ruby/info")
    }
    res = eval res.body
    if TYPE == "traffic"
      puts "tx.value #{res["traffic"]["tx"]}"
      puts "rx.value #{res["traffic"]["rx"]}"
    elsif TYPE == "connections"
      puts "number.value #{res["connections"]["number"]}"
      puts "active.value #{res["connections"]["active"]}"
      puts "reusable.value #{res["connections"]["reusable"]}"
    end
  rescue Exception => e
    puts e
    exit -1
  end
end

