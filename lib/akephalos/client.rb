require 'akephalos/configuration'

if RUBY_PLATFORM != "java"
  require 'akephalos/remote_client'
  Akephalos::Client = Akephalos::RemoteClient
else
  require 'akephalos/htmlunit'
  require 'akephalos/htmlunit/ext/http_method'

  require 'akephalos/page'
  require 'akephalos/node'

  require 'akephalos/client/filter'
  require 'akephalos/client/listener'

  module Akephalos
    class Client
      java_import 'com.gargoylesoftware.htmlunit.NicelyResynchronizingAjaxController'
      java_import 'com.gargoylesoftware.htmlunit.SilentCssErrorHandler'

      attr_reader :page

      def initialize
        @_client = java.util.concurrent.FutureTask.new do
          client = WebClient.new

          Filter.new(client)
          client.addWebWindowListener(Listener.new(self))
          client.setAjaxController(NicelyResynchronizingAjaxController.new)
          client.setCssErrorHandler(SilentCssErrorHandler.new)

          client
        end
        Thread.new { @_client.run }
      end

      def configuration=(config)
        Akephalos.configuration = config
      end

      def visit(url)
        client.getPage(url)
        page
      end

      def page=(_page)
        if @page != _page
          @page = Page.new(_page)
        end
        @page
      end

      private
      def client
        @client ||= @_client.get
      end
    end
  end
end
