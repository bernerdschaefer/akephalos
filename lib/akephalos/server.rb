require "pathname"
require "drb/drb"
require "akephalos/client"

# In ruby-1.8.7 and later, the message for a NameError exception is lazily
# evaluated. There are, however, different implementations of this between ruby
# and jruby, so we realize these messages when sending over DRb.
class NameError::Message
  def _dump
    to_s
  end
end

[Akephalos::Page, Akephalos::Node].each { |klass| klass.send(:include, DRbUndumped) }

module Akephalos

  # Akephalos::Server is used by `akephalos --server` to start a DRb server
  # serving an instance of Akephalos::Client.
  class Server
    # Start DRb service for an Akephalos::Client.
    #
    # @param [String] socket_file path to socket file to start
    def self.start!(socket_file)
      client = Client.new
      DRb.start_service("drbunix://#{socket_file}", client)
      DRb.thread.join
    end
  end

end
