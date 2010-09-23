# Driver class exposed to Capybara. It implements Capybara's full driver API,
# and is the entry point for interaction between the test suites and HtmlUnit.
#
# This class and +Capybara::Driver::Akephalos::Node+ are written to run on both
# MRI and JRuby, and is agnostic whether the Akephalos::Client instance is used
# directly or over DRb.
class Capybara::Driver::Akephalos < Capybara::Driver::Base

  # Akephalos-specific implementation for Capybara's Node class.
  class Node < Capybara::Node

    # @api capybara
    # @param [String] name attribute name
    # @return [String] the attribute value
    def [](name)
      name = name.to_s
      case name
      when 'checked'
        node.checked?
      else
        node[name.to_s]
      end
    end

    # @api capybara
    # @return [String] the inner text of the node
    def text
      node.text
    end

    # @api capybara
    # @return [String] the form element's value
    def value
      node.value
    end

    # Set the form element's value.
    #
    # @api capybara
    # @param [String] value the form element's new value
    def set(value)
      if tag_name == 'textarea'
        node.value = value.to_s
      elsif tag_name == 'input' and type == 'radio'
        click
      elsif tag_name == 'input' and type == 'checkbox'
        if value != self['checked']
          click
        end
      elsif tag_name == 'input'
        node.value = value.to_s
      end
    end

    # Select an option from a select box.
    #
    # @api capybara
    # @param [String] option the option to select
    def select(option)
      result = node.select_option(option)

      if result == nil
        options = node.options.map(&:text).join(", ")
        raise Capybara::OptionNotFound, "No such option '#{option}' in this select box. Available options: #{options}"
      else
        result
      end
    end

    # Unselect an option from a select box.
    #
    # @api capybara
    # @param [String] option the option to unselect
    def unselect(option)
      unless self[:multiple]
        raise Capybara::UnselectNotAllowed, "Cannot unselect option '#{option}' from single select box."
      end

      result = node.unselect_option(option)

      if result == nil
        options = node.options.map(&:text).join(", ")
        raise Capybara::OptionNotFound, "No such option '#{option}' in this select box. Available options: #{options}"
      else
        result
      end
    end

    # Trigger an event on the element.
    #
    # @api capybara
    # @param [String] event the event to trigger
    def trigger(event)
      node.fire_event(event.to_s)
    end

    # @api capybara
    # @return [String] the element's tag name
    def tag_name
      node.tag_name
    end

    # @api capybara
    # @return [true, false] the element's visiblity
    def visible?
      node.visible?
    end

    # Drag the element on top of the target element.
    #
    # @api capybara
    # @param [Node] element the target element
    def drag_to(element)
      trigger('mousedown')
      element.trigger('mousemove')
      element.trigger('mouseup')
    end

    # Click the element.
    def click
      node.click
    end

    private

    # Return all child nodes which match the selector criteria.
    #
    # @api capybara
    # @return [Array<Node>] the matched nodes
    def all_unfiltered(selector)
      nodes = []
      node.find(selector).each { |node| nodes << Node.new(driver, node) }
      nodes
    end

    # @return [String] the node's type attribute
    def type
      node[:type]
    end
  end

  attr_reader :app, :rack_server

  # @return [Client] an instance of Akephalos::Client
  def self.driver
    @driver ||= Akephalos::Client.new
  end

  def initialize(app)
    @app = app
    @rack_server = Capybara::Server.new(@app)
    @rack_server.boot if Capybara.run_server
  end

  # Visit the given path in the browser.
  #
  # @param [String] path relative path to visit
  def visit(path)
    browser.visit(url(path))
  end

  # @return [String] the page's original source
  def source
    page.source
  end

  # @return [String] the page's modified source
  def body
    page.modified_source
  end

  # @return [Hash{String => String}] the page's response headers
  def response_headers
    page.response_headers
  end

  # @return [Integer] the response's status code
  def status_code
    page.status_code
  end

  # Execute the given block within the context of a specified frame.
  #
  # @param [String] frame_id the frame's id
  # @raise [Capybara::ElementNotFound] if the frame is not found
  def within_frame(frame_id, &block)
    unless page.within_frame(frame_id, &block)
      raise Capybara::ElementNotFound, "Unable to find frame with id '#{frame_id}'"
    end
  end

  # Clear all cookie session data.
  # @deprecated This method is deprecated in Capybara's master branch. Use
  #   {#reset!} instead.
  def cleanup!
    reset!
  end

  # Clear all cookie session data.
  def reset!
    cookies.clear
  end

  # @return [String] the page's current URL
  def current_url
    page.current_url
  end

  # Search for nodes which match the given XPath selector.
  #
  # @param [String] selector XPath query
  # @return [Array<Node>] the matched nodes
  def find(selector)
    nodes = []
    page.find(selector).each { |node| nodes << Node.new(self, node) }
    nodes
  end

  # Execute JavaScript against the current page, discarding any return value.
  #
  # @param [String] script the JavaScript to be executed
  # @return [nil]
  def execute_script(script)
    page.execute_script script
  end

  # Execute JavaScript against the current page and return the results.
  #
  # @param [String] script the JavaScript to be executed
  # @return the result of the JavaScript
  def evaluate_script(script)
    page.evaluate_script script
  end

  # @return the current page
  def page
    browser.page
  end

  # @return the browser
  def browser
    self.class.driver
  end

  # @return the session cookies
  def cookies
    browser.cookies
  end

  # @return [String] the current user agent string
  def user_agent
    browser.user_agent
  end

  # Set the User-Agent header for this session. If :default is given, the
  # User-Agent header will be reset to the default browser's user agent.
  #
  # @param [:default] user_agent the default user agent
  # @param [String] user_agent the user agent string to use
  def user_agent=(user_agent)
    browser.user_agent = user_agent
  end

  # Disable waiting in Capybara, since waiting is handled directly by
  # Akephalos.
  #
  # @return [false]
  def wait
    false
  end

  private

  # @param [String] path
  # @return [String] the absolute URL for the given path
  def url(path)
    rack_server.url(path)
  end

end
