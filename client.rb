require 'rubygems'
require 'bundler/setup'
require_relative 'grpc/stream_services_pb'

stub = Stream::Stub.new("0.0.0.0:50052", :this_channel_is_insecure)
resps = stub.get_message(Response.new(id: ARGV[0].to_i))
resps.each do |r|
  p "- found #{r.id}"
end
