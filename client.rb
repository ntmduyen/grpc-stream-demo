require 'rubygems'
require 'bundler/setup'
require_relative 'grpc/stream_services_pb'

stub = Stream::Stub.new("0.0.0.0:50052", :this_channel_is_insecure)
resps = stub.get_message(Response.new(id: ARGV[0].to_i))
last_id = nil
resps.each do |r|
  if last_id && (last_id + 1) != r.id
    raise RuntimeError.new("missing event: #{last_id} #{r.id}")
  end
  last_id = r.id
  p "- found #{r.id}"
end
