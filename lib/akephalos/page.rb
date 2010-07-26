module Akephalos
  class Page
    def initialize(page)
      @nodes = []
      @_page = page
    end

    def find(selector)
      nodes = @_page.getByXPath(selector).map { |node| Node.new(node) }
      @nodes << nodes
      nodes
    end

    def modified_source
      @_page.asXml
    end

    def source
      @_page.getWebResponse.getContentAsString
    end

    def current_url
      @_page.getWebResponse.getRequestSettings.getUrl.toString
    end

    def execute_script(script)
      @_page.executeJavaScript(script)
      nil
    end

    def evaluate_script(script)
      @_page.executeJavaScript(script).getJavaScriptResult
    end

    def ==(other)
      @_page == other
    end
  end
end
