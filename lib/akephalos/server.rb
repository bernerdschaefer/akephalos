require "pathname"
require "drb/drb"
require "akephalos/client"

class NameError::Message
  def _dump
    to_s
  end
end

[
  Akephalos::Page,
  Akephalos::Node
].each { |klass| klass.send(:include, DRbUndumped) }

module Akephalos
  class Server
    def self.start!(socket_file)
      client = Client.new
      DRb.start_service("drbunix://#{socket_file}", client)
      DRb.thread.join
    end
  end
end
