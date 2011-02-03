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
      attr_reader :page

      def initialize
        @_client = java.util.concurrent.FutureTask.new do
          client = HtmlUnit::WebClient.new

          Filter.new(client)
          client.setThrowExceptionOnFailingStatusCode(false)
          client.setAjaxController(HtmlUnit::NicelyResynchronizingAjaxController.new)
          client.setCssErrorHandler(HtmlUnit::SilentCssErrorHandler.new)
          client.setThrowExceptionOnScriptError(false);
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

      # @return [String] the current user agent string
      def user_agent
        @user_agent || client.getBrowserVersion.getUserAgent
      end

      # Set the User-Agent header for this session. If :default is given, the
      # User-Agent header will be reset to the default browser's user agent.
      #
      # @param [:default] user_agent the default user agent
      # @param [String] user_agent the user agent string to use
      def user_agent=(user_agent)
        if user_agent == :default
          @user_agent = nil
          client.removeRequestHeader("User-Agent")
        else
          @user_agent = user_agent
          client.addRequestHeader("User-Agent", user_agent)
        end
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
