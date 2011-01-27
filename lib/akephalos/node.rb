module Akephalos

  # Akephalos::Node wraps HtmlUnit's DOMNode class, providing a simple API for
  # interacting with an element on the page.
  class Node
    # @param [HtmlUnit::DOMNode] node
    def initialize(node)
      @nodes = []
      @_node = node
    end

    # @return [true, false] whether the element is checked
    def checked?
      @_node.isChecked
    end

    # @return [String] inner text of the node
    def text
      @_node.asText
    end

    # Return the value of the node's attribute.
    #
    # @param [String] name attribute on node
    # @return [String] the value of the named attribute
    # @return [nil] when the node does not have the named attribute
    def [](name)
      @_node.hasAttribute(name.to_s) ? @_node.getAttribute(name.to_s) : nil
    end

    # Return the value of a form element. If the element is a select box and
    # has "multiple" declared as an attribute, then all selected options will
    # be returned as an array.
    #
    # @return [String, Array<String>] the node's value
    def value
      case tag_name
      when "select"
        if self[:multiple]
          selected_options.map { |option| option.value }
        else
          selected_option = @_node.selected_options.first
          selected_option ? Node.new(selected_option).value : nil
        end
      when "option"
        self[:value] || text
      when "textarea"
        @_node.getText
      else
        self[:value]
      end
    end

    # Set the value of the form input.
    #
    # @param [String] value
    def value=(value)
      case tag_name
      when "textarea"
        @_node.setText("")
        type(value)
      when "input"
        if file_input?
          @_node.setValueAttribute(value)
        else
          @_node.setValueAttribute("")
          type(value)
        end
      end
    end

    # Types each character into a text or input field.
    #
    # @param [String] value the string to type
    def type(value)
      value.each_char do |c|
        @_node.type(c)
      end
    end

    # @return [true, false] whether the node allows multiple-option selection (if the node is a select).
    def multiple_select?
      !self[:multiple].nil?
    end

    # @return [true, false] whether the node is a file input
    def file_input?
      tag_name == "input" && @_node.getAttribute("type") == "file"
    end


    # Unselect an option.
    #
    # @return [true, false] whether the unselection was successful
    def unselect
      @_node.setSelected(false)
    end

    # Return the option elements for a select box.
    #
    # @return [Array<Node>] the options
    def options
      @_node.getOptions.map { |node| Node.new(node) }
    end

    # Return the selected option elements for a select box.
    #
    # @return [Array<Node>] the selected options
    def selected_options
      @_node.getSelectedOptions.map { |node| Node.new(node) }
    end

    # Fire a JavaScript event on the current node. Note that you should not
    # prefix event names with "on", so:
    #
    #   link.fire_event('mousedown')
    #
    # @param [String] JavaScript event name
    def fire_event(name)
      @_node.fireEvent(name)
    end

    # @return [String] the node's tag name
    def tag_name
      @_node.getNodeName
    end

    # @return [true, false] whether the node is visible to the user accounting
    # for CSS.
    def visible?
      @_node.isDisplayed
    end

    def selected?
      @_node.isSelected
    end

    # Click the node and then wait for any triggered JavaScript callbacks to
    # fire.
    def click
      @_node.click
      @_node.getPage.getEnclosingWindow.getJobManager.waitForJobs(1000)
      @_node.getPage.getEnclosingWindow.getJobManager.waitForJobsStartingBefore(1000)
    end

    # Search for child nodes which match the given XPath selector.
    #
    # @param [String] selector an XPath selector
    # @return [Array<Node>] the matched nodes
    def find(selector)
      nodes = @_node.getByXPath(selector).map { |node| Node.new(node) }
      @nodes << nodes
      nodes
    end

    # @return [String] the XPath expression for this node
    def xpath
      @_node.getCanonicalXPath
    end
  end

end
