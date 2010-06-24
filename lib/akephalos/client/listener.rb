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
      end
    end
  end
end
