require 'rubydns'

UPSTREAM="8.8.8.8"
LOCAL="0.0.0.0"

class Server < RubyDNS::Server
  UPSTREAM = RubyDNS::Resolver.new([[:udp, UPSTREAM, 53], [:tcp, UPSTREAM, 53]])
        IN = Resolv::DNS::Resource::IN

  def start!
    EventMachine.run do
      run(:listen => [[:tcp, LOCAL, 53],
        [:udp, LOCAL, 53]])
    end
  end

  def stop!
    fire :stop
    EventMachine::stop_event_loop
  rescue
  end

  def process(name, resource_class, transaction)
    transaction.passthrough! UPSTREAM do |response|
      response.answer.each do |answer|
        answer[1] = 0
        answer[2].instance_eval do
          @ttl = 0 
        end
      end
    end
  end
end

Server.new.start!
