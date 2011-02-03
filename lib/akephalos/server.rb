require "pathname"
require "drb/drb"
require "akephalos/client"

# In ruby-1.8.7 and later, the message for a NameError exception is lazily
# evaluated. There are, however, different implementations of this between ruby
# and jruby, so we realize these messages when sending over DRb.
class NameError::Message
  # @note This method is called by DRb before sending the error to the remote
  # connection.
  # @return [String] the inner message.
  def _dump
    to_s
  end
end

[
  Akephalos::Page,
  Akephalos::Node,
  Akephalos::Client::Cookies,
  Akephalos::Client::Cookies::Cookie
].each { |klass| klass.send(:include, DRbUndumped) }

module Akephalos

  # The ClientManager is shared over DRb with the remote process, and
  # facilitates communication between the processes.
  #
  # @api private
  class ClientManager
    include DRbUndumped

    # @return [Akephalos::Client] a new client instance
    def self.new_client
      # Store the client to ensure it isn't prematurely garbage collected.
      @client = Client.new
    end

    # Set the global configuration settings for Akephalos.
    #
    # @param [Hash] config the configuration settings
    # @return [Hash] the configuration
    def self.configuration=(config)
      Akephalos.configuration = config
    end

  end

  # Akephalos::Server is used by `akephalos --server` to start a DRb server
  # serving Akephalos::ClientManager.
  class Server

    # Start DRb service for Akephalos::ClientManager.
    #
    # @param [String] port attach server to
    def self.start!(port)
      abort_on_parent_exit!
      DRb.start_service("druby://127.0.0.1:#{port}", ClientManager)
      DRb.thread.join
    end

    private

    # Exit if STDIN is no longer readable, which corresponds to the process
    # which started the server exiting prematurely.
    #
    # @api private
    def self.abort_on_parent_exit!
      Thread.new do
        begin
          STDIN.read
        rescue IOError
          exit
        end
      end
    end
  end

end
