module Akephalos
  module Htmlunit
    module HtmlPage

      def modified_source
        asXml
      end

      def source
        getWebResponse.getContentAsString
      end

      def current_url
        getWebResponse.getRequestSettings.getUrl.toString
      end

      def find(selector)
        getByXPath(selector)
      end

      def execute_script(script)
        executeJavaScript(script).getJavaScriptResult
      end

      com.gargoylesoftware.htmlunit.html.HtmlPage.send(:include, self)
    end
  end
end
