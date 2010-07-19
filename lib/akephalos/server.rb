# This file runs a JRuby DRb server, and is run by `akephalos --server`.
require "pathname"
require "drb/drb"
require "akephalos/client"

# In ruby-1.8.7 and later, the message for a NameError exception is lazily
# evaluated. There are, however, different implementations of this between ruby
# and jrby, so we realize these messages when sending over DRb.
class NameError::Message
  def _dump
    to_s
  end
end

[Akephalos::Page, Akephalos::Node].each { |klass| klass.send(:include, DRbUndumped) }

module Akephalos
  class Server
    def self.start!(socket_file)
      client = Client.new
      DRb.start_service("drbunix://#{socket_file}", client)
      DRb.thread.join
    end
  end
end
