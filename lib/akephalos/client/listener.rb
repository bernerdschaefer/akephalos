module Akephalos
  class Client
    class Listener
      include com.gargoylesoftware.htmlunit.WebWindowListener

      def initialize(client)
        @client = client
      end

      def webWindowClosed(event)
      end

      def webWindowContentChanged(event)
        @client.page = event.getNewPage
        if latch = Thread.current[:latch]
          latch.countDown
          Thread.current[:latch] = nil
        end
      end
    end
  end
end
