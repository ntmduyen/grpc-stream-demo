# Generated by the protocol buffer compiler.  DO NOT EDIT!
# Source: stream.proto for package ''

require 'grpc'
require 'concurrent'
require 'concurrent-edge'
require_relative 'stream_pb'

module Stream
  class Service

    include GRPC::GenericService

    self.marshal_class_method = :encode
    self.unmarshal_class_method = :decode
    self.service_name = 'Stream'

    rpc :GetMessage, Request, stream(Response)
  end

  Stub = Service.rpc_stub_class
end

class RespEnumerator
  def initialize(channel, id)
    @id = id.to_i
    puts "new client id: #{@id}"
    queue = Queue.new
    Concurrent::Actor::Utils::AdHoc.spawn "client-#{id}" do
      channel << :subscribe
      lambda do |event|
        puts "client-#{id}: push to queue\n"
        queue.push(event)
      end
    end
    @queue = queue
  end

  def each
    return enum_for(:each) unless block_given?
    begin
      puts "client-#{@id}: response"
      while 1
        yield Response.new(id: @queue.shift)
      end
    rescue StandardError => e
      fail e # signal completion via an error
    end
  end
end

class SimpleStream < Stream::Service
  def initialize(channel)
    @channel = channel
  end

  def get_message(req, _)
    id = req.id
    RespEnumerator.new(@channel, id).each
  end
end
