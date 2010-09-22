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
    @socket_file = "/tmp/akephalos.#{Process.pid}.sock"

    # Start a remote akephalos server and return the remote Akephalos::Client
    # instance.
    #
    # @return [DRbObject] the remote client instance
    def self.new
      start!
      DRb.start_service
      client = DRbObject.new_with_uri("drbunix://#{@socket_file}")
      # We want to share our local configuration with the remote server
      # process, so we share an undumped version of our configuration. This
      # lets us continue to make changes locally and have them reflected in the
      # remote process.
      client.configuration = Akephalos.configuration.extend(DRbUndumped)
      client
    end

    # Start a remote server process and return when it is available for use.
    def self.start!
      remote_client = IO.popen("#{Akephalos::BIN_DIR + 'akephalos'} #{@socket_file}")

      # Set up a monitor thread to detect if the forked server exits
      # prematurely.
      server_monitor = Thread.new { Thread.current[:exited] = Process.wait(remote_client.pid) }

      # Wait for the server to be accessible on the socket we specified.
      until File.exists?(@socket_file)
        exit!(1) if server_monitor[:exited]
        sleep 0.5
      end
      server_monitor.kill

      # Ensure that the remote server shuts down gracefully when we are
      # finished.
      at_exit { Process.kill(:INT, remote_client.pid); File.unlink(@socket_file) }
    end
  end
end
