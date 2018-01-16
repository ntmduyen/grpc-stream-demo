require 'rubygems'
require 'bundler/setup'
require_relative 'grpc/stream_services_pb'

class EventBroadcast
  def self.start(channel)
    service = new(channel)
    loop do
      service.gen_events
    end
  end

  def initialize(channel)
    @channel = channel
  end

  def gen_events
    sleep 3
    @channel << rand(100)
  end
end

class StreamServer
  def self.start(channel)
    start_grpc_server(channel)
  end

  def self.start_grpc_server(channel)
    port = "0.0.0.0:50052"
    puts "Starting Server on port #{port}"
    server = GRPC::RpcServer.new
    server.add_http2_port(port, :this_port_is_insecure)
    server.handle(SimpleStream.new(channel))
    server.run_till_terminated
  end
end
channel = Concurrent::Actor::Utils::Broadcast.spawn :event
Thread.new do
  EventBroadcast.start(channel)
end
StreamServer.start(channel)
