module Akephalos
  module Htmlunit
    module HtmlPage
      def source
        writer = StringWriter.new
        printer = PrintWriter.new(writer)
        printXml('', printer)
        printer.close
        writer.toString
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
