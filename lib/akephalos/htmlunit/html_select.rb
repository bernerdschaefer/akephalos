module Akephalos
  module Htmlunit
    module HtmlSelect
      def select_option(option)
        opt = getOptions.detect { |o| o.asText == option }

        opt && opt.setSelected(true)
      end

      def unselect_option(option)
        opt = getOptions.detect { |o| o.asText == option }

        opt && opt.setSelected(false)
      end

      com.gargoylesoftware.htmlunit.html.HtmlSelect.send(:include, self)
    end
  end
end
