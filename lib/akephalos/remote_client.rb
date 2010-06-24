require 'drb/drb'

class NativeException < StandardError; end

module Akephalos
  class RemoteClient
    @socket_file = "/tmp/akephalos.#{Process.pid}.sock"

    def self.start!
      remote_client = fork do
        exec("#{Akephalos::BIN_DIR + 'akephalos'} #{@socket_file}")
      end

      sleep 1 until File.exists?(@socket_file)

      at_exit { Process.kill(:INT, remote_client); File.unlink(@socket_file) }
    end

    def self.new
      start!
      DRb.start_service
      client = DRbObject.new_with_uri("drbunix://#{@socket_file}")
      client.configuration = Akephalos.configuration.extend(DRbUndumped)
      client
    end
  end
end
