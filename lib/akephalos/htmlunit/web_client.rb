module Akephalos
  module Htmlunit
    module WebClient

      def visit(url)
        getPage(url)
      end

      def page
        getCurrentWindow.getEnclosedPage
      end

      com.gargoylesoftware.htmlunit.WebClient.send(:include, self)
    end
  end
end
