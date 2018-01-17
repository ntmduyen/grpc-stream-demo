require 'rubygems'
require 'bundler/setup'
require_relative 'grpc/stream_services_pb'

class EventBroadcast
  def self.start(subscriptions)
    service = new(subscriptions)
    loop do
      service.gen_events
    end
  end

  def initialize(subscriptions)
    @subscriptions = subscriptions
    @counter = 0
  end

  def gen_events
    sleep 3
    @subscriptions.each do |s|
      s << @counter
    end
    @counter += 1
  end
end

class StreamServer
  def self.start(subscriptions)
    start_grpc_server(subscriptions)
  end

  def self.start_grpc_server(subscriptions)
    port = "0.0.0.0:50052"
    puts "Starting Server on port #{port}"
    server = GRPC::RpcServer.new
    server.add_http2_port(port, :this_port_is_insecure)
    server.handle(SimpleStream.new(subscriptions))
    server.run_till_terminated
  end
end

subscriptions = Set.new
Thread.new do
  EventBroadcast.start(subscriptions)
end
StreamServer.start(subscriptions)
