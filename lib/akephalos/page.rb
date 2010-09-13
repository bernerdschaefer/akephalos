module Akephalos

  # Akephalos::Page wraps HtmlUnit's HtmlPage class, exposing an API for
  # interacting with a page in the browser.
  class Page
    # @param [HtmlUnit::HtmlPage] page
    def initialize(page)
      @nodes = []
      @_page = page
    end

    # Search for nodes which match the given XPath selector.
    #
    # @param [String] selector an XPath selector
    # @return [Array<Node>] the matched nodes
    def find(selector)
      nodes = @_page.getByXPath(selector).map { |node| Node.new(node) }
      @nodes << nodes
      nodes
    end

    # Return the page's source, including any JavaScript-triggered DOM changes.
    #
    # @return [String] the page's modified source
    def modified_source
      @_page.asXml
    end

    # Return the page's source as returned by the web server.
    #
    # @return [String] the page's original source
    def source
      @_page.getWebResponse.getContentAsString
    end

    # @return [Hash{String => String}] the page's response headers
    def response_headers
      headers = @_page.getWebResponse.getResponseHeaders.map do |header|
        [header.getName, header.getValue]
      end
      Hash[*headers.flatten]
    end

    # @return [String] the current page's URL.
    def current_url
      @_page.getWebResponse.getRequestSettings.getUrl.toString
    end

    # Execute JavaScript against the current page, discarding any return value.
    #
    # @param [String] script the JavaScript to be executed
    # @return [nil]
    def execute_script(script)
      @_page.executeJavaScript(script)
      nil
    end

    # Execute JavaScript against the current page and return the results.
    #
    # @param [String] script the JavaScript to be executed
    # @return the result of the JavaScript
    def evaluate_script(script)
      @_page.executeJavaScript(script).getJavaScriptResult
    end

    # Compare this page with an HtmlUnit page.
    #
    # @param [HtmlUnit::HtmlPage] other an HtmlUnit page
    # @return [true, false]
    def ==(other)
      @_page == other
    end
  end

end
