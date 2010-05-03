class Capybara::Driver::Akephalos < Capybara::Driver::Base

  class Node < Capybara::Node

    def [](name)
      name = name.to_s
      case name
      when 'checked'
        node.isChecked
      else
        node[name.to_s]
      end
    end

    def text
      node.asText
    end

    def value
      if tag_name == "select" && self[:multiple]
        node.getSelectedOptions.map { |n| n.asText }
      elsif tag_name == "select"
        node.getSelectedOptions.first.asText
      else
        super
      end
    end

    def set(value)
      if tag_name == 'textarea'
        node.setText(value.to_s)
      elsif tag_name == 'input' and %w(text password hidden file).include?(type)
        node.setValueAttribute(value.to_s)
      elsif tag_name == 'input' and type == 'radio'
        node.click
      elsif tag_name == 'input' and type == 'checkbox'
        node.click
      end
    end

    def select(option)
      result = node.select_option(option)

      if result == nil
        options = node.getOptions.map { |opt| opt.asText }.join(", ")
        raise Capybara::OptionNotFound, "No such option '#{option}' in this select box. Available options: #{options}"
      else
        result
      end
    end

    def unselect(option)
      unless self[:multiple]
        raise Capybara::UnselectNotAllowed, "Cannot unselect option '#{option}' from single select box."
      end

      result = node.unselect_option(option)

      if result == nil
        options = node.getOptions.map { |opt| opt.asText }.join(", ")
        raise Capybara::OptionNotFound, "No such option '#{option}' in this select box. Available options: #{options}"
      else
        result
      end
    end

    def trigger(event)
      node.fire_event(event.to_s)
    end

    def tag_name
      node.getNodeName
    end

    def visible?
      node.isDisplayed
    end

    def drag_to(element)
      node.fire_event('mousedown')
      element.node.fire_event('mousemove')
      element.node.fire_event('mouseup')
    end

    def click
      node.click
    end

    private

    def all_unfiltered(selector)
      node.getByXPath(selector).map { |n| self.class.new(driver, n) }
    end

    def type
      node[:type]
    end
  end

  attr_reader :app, :rack_server

  def self.driver
    if RUBY_PLATFORM == "java"
      require '/usr/local/projects/personal/htmlunit-ruby/jruby'
      @driver ||= WebClient.new
    else
      @driver ||= begin
        uri = "drbunix:///tmp/htmlunit.sock"
        DRb.start_service
        client_class = DRbObject.new_with_uri(uri)
        at_exit { client_class.cleanup! }
        client_class.new
      end
    end
  end

  def initialize(app)
    @app = app
    @rack_server = Capybara::Server.new(@app)
    @rack_server.boot if Capybara.run_server
  end

  def visit(path)
    browser.visit(url(path))
  end

  def source
    page.source
  end
  alias body source

  def current_url
    page.current_url
  end

  def find(selector)
    page.find(selector).map { |node| Node.new(self, node) }
  end

  def evaluate_script(script)
    page.execute_script script
  end

  def page
    browser.page
  end

  def browser
    self.class.driver
  end

  def wait?; true end

private

  def url(path)
    rack_server.url(path)
  end

end
