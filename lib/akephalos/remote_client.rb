require 'socket'
require 'drb/drb'

# We need to define our own NativeException class for the cases when a native
# exception is raised by the JRuby DRb server.
class NativeException < StandardError; end

module Akephalos

  # The +RemoteClient+ class provides an interface to an +Akephalos::Client+
  # isntance on a remote DRb server.
  #
  # == Usage
  #     client = Akephalos::RemoteClient.new
  #     client.visit "http://www.oinopa.com"
  #     client.page.source # => "<!DOCTYPE html PUBLIC..."
  class RemoteClient
    # @return [DRbObject] a new instance of Akephalos::Client from the DRb
    #   server
    def self.new(options = {})
      manager.new_client(options)
    end

    # Starts a remove JRuby DRb server unless already running and returns an
    # instance of Akephalos::ClientManager.
    #
    # @return [DRbObject] an instance of Akephalos::ClientManager
    def self.manager
      return @manager if defined?(@manager)

      server_port = start!

      DRb.start_service
      manager = DRbObject.new_with_uri("druby://127.0.0.1:#{server_port}")

      # We want to share our local configuration with the remote server
      # process, so we share an undumped version of our configuration. This
      # lets us continue to make changes locally and have them reflected in the
      # remote process.
      manager.configuration = Akephalos.configuration.extend(DRbUndumped)

      @manager = manager
    end

    # Start a remote server process and return when it is available for use.
    def self.start!
      port = find_available_port

      remote_client = IO.popen("ruby #{Akephalos::BIN_DIR + 'akephalos'} #{port}")

      # Set up a monitor thread to detect if the forked server exits
      # prematurely.
      server_monitor = Thread.new { Thread.current[:exited] = Process.wait(remote_client.pid) }

      # Wait for the server to be accessible on the socket we specified.
      until responsive?(port)
        exit!(1) if server_monitor[:exited]
        sleep 0.5
      end
      server_monitor.kill

      # Ensure that the remote server shuts down gracefully when we are
      # finished.
      at_exit { Process.kill(:INT, remote_client.pid) }

      port
    end

    private

    # @api private
    # @param [Integer] port the port to check for responsiveness
    # @return [true, false] whether the port is responsive
    def self.responsive?(port)
      socket = TCPSocket.open('127.0.0.1', port)
      true
    rescue Errno::ECONNREFUSED
      false
    ensure
      socket.close if socket
    end

    # @api private
    # @return [Integer] the next available port
    def self.find_available_port
      server = TCPServer.new('127.0.0.1', 0)
      server.addr[1]
    ensure
      server.close if server
    end
  end
end
