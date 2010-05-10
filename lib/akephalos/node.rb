module Akephalos
  class Node
    def initialize(node)
      @_node = node
    end

    def checked?
      @_node.isChecked
    end

    def text
      @_node.asText
    end

    def [](name)
      @_node.hasAttribute(name.to_s) ? @_node.getAttribute(name.to_s) : nil
    end

    def value=(value)
      case tag_name
      when "textarea"
        @_node.setText(value)
      when "input"
        @_node.setValueAttribute(value)
      end
    end

    def select_option(option)
      opt = @_node.getOptions.detect { |o| o.asText == option }

      opt && opt.setSelected(true)
    end

    def unselect_option(option)
      opt = @_node.getOptions.detect { |o| o.asText == option }

      opt && opt.setSelected(false)
    end

    def options
      @_node.getOptions.map { |node| Node.new(node) }
    end

    def selected_options
      @_node.getSelectedOptions.map { |node| Node.new(node) }
    end

    def fire_event(name)
      @_node.fireEvent(name)
    end

    def tag_name
      @_node.getNodeName
    end

    def visible?
      @_node.isDisplayed
    end

    def click
      @_node.click
    end

    def find(selector)
      @_node.getByXPath(selector).map { |node| Node.new(node) }
    end
  end
end
