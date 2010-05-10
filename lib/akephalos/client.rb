if RUBY_PLATFORM != "java"
  require 'akephalos/remote_client'
  Akephalos::Client = Akephalos::RemoteClient
else
  require 'akephalos/htmlunit'
  require 'akephalos/page'
  require 'akephalos/node'

  module Akephalos
    class Client
      def initialize
        @_client = WebClient.new
        @_client.setCssErrorHandler(com.gargoylesoftware.htmlunit.SilentCssErrorHandler.new)
      end

      def visit(url)
        @page = Page.new(@_client.getPage(url))
      end

      def page
        if @page != (page = @_client.getCurrentWindow.getEnclosedPage)
          @page = Page.new(page)
        end
        @page
      end
    end
  end
end
