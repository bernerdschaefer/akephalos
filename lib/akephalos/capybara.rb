class NativeException < StandardError; end
class Capybara::Driver::Akephalos < Capybara::Driver::Base

  class Node < Capybara::Node

    def [](name)
      name = name.to_s
      case name
      when 'checked'
        node.checked?
      else
        node[name.to_s]
      end
    end

    def text
      node.text
    end

    def value
      if tag_name == "select" && self[:multiple]
        node.selected_options.map { |option| option.text }
      elsif tag_name == "select"
        selected_option = node.selected_options.first
        selected_option ? selected_option.text : nil
      else
        self[:value]
      end
    end

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

    def select(option)
      result = node.select_option(option)

      if result == nil
        options = node.options.map(&:text).join(", ")
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
        options = node.options.map(&:text).join(", ")
        raise Capybara::OptionNotFound, "No such option '#{option}' in this select box. Available options: #{options}"
      else
        result
      end
    end

    def trigger(event)
      node.fire_event(event.to_s)
    end

    def tag_name
      node.tag_name
    end

    def visible?
      node.visible?
    end

    def drag_to(element)
      trigger('mousedown')
      element.trigger('mousemove')
      element.trigger('mouseup')
    end

    def click
      node.click
    end

    private

    def all_unfiltered(selector)
      nodes = []
      node.find(selector).each { |node| nodes << Node.new(driver, node) }
      nodes
    end

    def type
      node[:type]
    end
  end

  attr_reader :app, :rack_server

  def self.driver
    @driver ||= Akephalos::Client.new
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

  def body
    page.modified_source
  end

  def current_url
    page.current_url
  end

  def find(selector)
    nodes = []
    page.find(selector).each { |node| nodes << Node.new(self, node) }
    nodes
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

  def wait
    false
  end

private

  def url(path)
    rack_server.url(path)
  end

end
