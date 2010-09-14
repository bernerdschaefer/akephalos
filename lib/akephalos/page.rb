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
      nodes = current_frame.getByXPath(selector).map { |node| Node.new(node) }
      @nodes << nodes
      nodes
    end

    # Return the page's source, including any JavaScript-triggered DOM changes.
    #
    # @return [String] the page's modified source
    def modified_source
      current_frame.asXml
    end

    # Return the page's source as returned by the web server.
    #
    # @return [String] the page's original source
    def source
      current_frame.getWebResponse.getContentAsString
    end

    # @return [Hash{String => String}] the page's response headers
    def response_headers
      headers = current_frame.getWebResponse.getResponseHeaders.map do |header|
        [header.getName, header.getValue]
      end
      Hash[*headers.flatten]
    end

    # @return [Integer] the response's status code
    def status_code
      current_frame.getWebResponse.getStatusCode
    end

    # Execute the given block in the context of the frame specified.
    #
    # @param [String] frame_id the frame's id
    # @return [true] if the frame is found
    # @return [nil] if the frame is not found
    def within_frame(frame_id)
      return unless @current_frame = find_frame(frame_id)
      yield
      true
    ensure
      @current_frame = nil
    end

    # @return [String] the current page's URL.
    def current_url
      current_frame.getWebResponse.getRequestSettings.getUrl.toString
    end

    # Execute JavaScript against the current page, discarding any return value.
    #
    # @param [String] script the JavaScript to be executed
    # @return [nil]
    def execute_script(script)
      current_frame.executeJavaScript(script)
      nil
    end

    # Execute JavaScript against the current page and return the results.
    #
    # @param [String] script the JavaScript to be executed
    # @return the result of the JavaScript
    def evaluate_script(script)
      current_frame.executeJavaScript(script).getJavaScriptResult
    end

    # Compare this page with an HtmlUnit page.
    #
    # @param [HtmlUnit::HtmlPage] other an HtmlUnit page
    # @return [true, false]
    def ==(other)
      @_page == other
    end

    private

    # Return the current frame. Usually just @_page, except when inside of the
    # within_frame block.
    #
    # @return [HtmlUnit::HtmlPage] the current frame
    def current_frame
      @current_frame || @_page
    end

    # @param [String] id the frame's id
    # @return [HtmlUnit::HtmlPage] the specified frame
    # @return [nil] if no frame is found
    def find_frame(id)
      frame = @_page.getFrames.find do |frame|
        frame.getFrameElement.getAttribute("id") == id
      end
      frame.getEnclosedPage if frame
    end
  end

end
