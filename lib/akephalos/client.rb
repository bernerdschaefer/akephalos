require 'akephalos/configuration'

if RUBY_PLATFORM != "java"
  require 'akephalos/remote_client'
  Akephalos::Client = Akephalos::RemoteClient
else
  require 'akephalos/htmlunit'
  require 'akephalos/htmlunit/ext/http_method'

  require 'akephalos/page'
  require 'akephalos/node'

  require 'akephalos/client/cookies'
  require 'akephalos/client/filter'

  module Akephalos

    # Akephalos::Client wraps HtmlUnit's WebClient class. It is the main entry
    # point for all interaction with the browser, exposing its current page and
    # allowing navigation.
    class Client
      java_import 'com.gargoylesoftware.htmlunit.NicelyResynchronizingAjaxController'
      java_import 'com.gargoylesoftware.htmlunit.SilentCssErrorHandler'

      attr_reader :page

      def initialize
        @_client = java.util.concurrent.FutureTask.new do
          client = WebClient.new

          Filter.new(client)
          client.setAjaxController(NicelyResynchronizingAjaxController.new)
          client.setCssErrorHandler(SilentCssErrorHandler.new)

          client
        end
        Thread.new { @_client.run }
      end

      # Set the global configuration settings for Akephalos.
      #
      # @note This is only used when communicating over DRb, since just a
      # single client instance is exposed.
      # @param [Hash] config the configuration settings
      # @return [Hash] the configuration
      def configuration=(config)
        Akephalos.configuration = config
      end

      # Visit the requested URL and return the page.
      #
      # @param [String] url the URL to load
      # @return [Page] the loaded page
      def visit(url)
        client.getPage(url)
        page
      end

      # @return [Cookies] the cookies for this session
      def cookies
        @cookies ||= Cookies.new(client.getCookieManager)
      end

      # @return [Page] the current page
      def page
        self.page = client.getCurrentWindow.getTopWindow.getEnclosedPage
        @page
      end

      # Update the current page.
      #
      # @param [HtmlUnit::HtmlPage] _page the new page
      # @return [Page] the new page
      def page=(_page)
        if @page != _page
          @page = Page.new(_page)
        end
        @page
      end

      private

      # Call the future set up in #initialize and return the WebCLient
      # instance.
      #
      # @return [HtmlUnit::WebClient] the WebClient instance
      def client
        @client ||= @_client.get.tap do |client|
          client.getCurrentWindow.getHistory.ignoreNewPages_.set(true)
        end
      end
    end
  end
end
