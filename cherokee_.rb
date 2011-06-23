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
  puts "graph_title #{TYPE.capitalize} for #{HOST}"
  puts "graph_vlabel #{TYPE}"
  puts "#{TYPE}.label #{TYPE}"
  puts "#{TYPE}.type COUNTER"
else
  begin
    url = URI.parse("http://#{HOST}")
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.get("/status/ruby/info")
    }
    res = eval res.body
    puts "#{TYPE}.value #{res["traffic"]["tx"]}"
    #puts res["traffic"]["rx"]
  rescue Exception => e
    puts e
    exit -1
  end
end

