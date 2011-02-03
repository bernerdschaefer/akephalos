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

      # @return [Akephalos::Page] the current page
      attr_reader :page

      # @return [HtmlUnit::BrowserVersion] the configured browser version
      attr_reader :browser_version

      # @return [true/false] whether to raise errors on javascript failures
      attr_reader :validate_scripts

      # The default configuration options for a new Client.
      DEFAULT_OPTIONS = {
        :browser => :firefox_3_6,
        :validate_scripts => true
      }

      # Map of browser version symbols to their HtmlUnit::BrowserVersion
      # instances.
      BROWSER_VERSIONS = {
        :ie6         => HtmlUnit::BrowserVersion::INTERNET_EXPLORER_6,
        :ie7         => HtmlUnit::BrowserVersion::INTERNET_EXPLORER_7,
        :ie8         => HtmlUnit::BrowserVersion::INTERNET_EXPLORER_8,
        :firefox_3   => HtmlUnit::BrowserVersion::FIREFOX_3,
        :firefox_3_6 => HtmlUnit::BrowserVersion::FIREFOX_3_6
      }

      # @param [Hash] options the configuration options for this client
      #
      # @option options [Symbol] :browser (:firefox_3_6) the browser version (
      #   see BROWSER_VERSIONS)
      #
      # @option options [true, false] :validate_scripts (true) whether to raise
      #   errors on javascript errors
      def initialize(options = {})
        process_options!(options)

        @_client = java.util.concurrent.FutureTask.new do
          client = HtmlUnit::WebClient.new(browser_version)

          Filter.new(client)
          client.setThrowExceptionOnFailingStatusCode(false)
          client.setAjaxController(HtmlUnit::NicelyResynchronizingAjaxController.new)
          client.setCssErrorHandler(HtmlUnit::SilentCssErrorHandler.new)
          client.setThrowExceptionOnScriptError(validate_scripts)
          client
        end
        Thread.new { @_client.run }
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

      # @return [true, false] whether javascript errors will raise exceptions
      def validate_scripts?
        !!validate_scripts
      end

      # Merges the DEFAULT_OPTIONS with those provided to initialize the Client
      # state, namely, its browser version and whether it should
      # validate scripts.
      #
      # @param [Hash] options the options to process
      def process_options!(options)
        options = DEFAULT_OPTIONS.merge(options)

        @browser_version  = BROWSER_VERSIONS.fetch(options.delete(:browser))
        @validate_scripts = options.delete(:validate_scripts)
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
