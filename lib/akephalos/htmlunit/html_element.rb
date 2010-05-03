module Akephalos
  module Htmlunit
    module HtmlElement
      def [](name)
        hasAttribute(name.to_s) ? getAttribute(name.to_s) : nil
      end

      com.gargoylesoftware.htmlunit.html.HtmlElement.send(:include, self)
    end
  end
end
