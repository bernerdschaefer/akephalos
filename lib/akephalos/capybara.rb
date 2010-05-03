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
        values = []
        results = node.getSelectedOptions
        while (i ||= 0) < results.size
          values << results[i].asText
          i += 1
        end
        values
      elsif tag_name == "select"
        node.getSelectedOptions.first.asText
      else
        super
      end
    end

    def set(value)
      if tag_name == 'textarea'
        node.setText(value.to_s)
      elsif tag_name == 'input' and type == 'radio'
        node.click
      elsif tag_name == 'input' and type == 'checkbox'
        node.click
      elsif tag_name == 'input'
        node.setValueAttribute(value.to_s)
      end
    end

    def select(option)
      result = node.select_option(option)

      if result == nil
        options = []
        results = node.getOptions
        while (i ||= 0) < results.size
          options << results[i].asText
          i += 1
        end
        options = options.join(", ")
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
        options = []
        results = node.getOptions
        while (i ||= 0) < results.size
          options << results[i].asText
          i += 1
        end
        options = options.join(", ")
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
      nodes = []
      results = node.getByXPath(selector)
      while (i ||= 0) < results.size
        nodes << Node.new(driver, results[i])
        i += 1
      end
      nodes
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
        socket_file = "/tmp/akephalos.#{Process.pid}.sock"
        uri = "drbunix://#{socket_file}"

        server = fork do
          exec("#{Pathname(__FILE__).dirname.parent.parent + 'bin/akephalos'} #{socket_file}")
        end

        DRb.start_service

        sleep 1 until File.exists?(socket_file)

        client_class = DRbObject.new_with_uri(uri)

        at_exit { Process.kill(:INT, server); File.unlink(socket_file) }
        client_class
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

  def body
    page.modified_source
  end

  def current_url
    page.current_url
  end

  def find(selector)
    nodes = []
    results = page.find(selector)
    while (i ||= 0) < results.size
      nodes << Node.new(self, results[i])
      i += 1
    end
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

  def wait?; true end

private

  def url(path)
    rack_server.url(path)
  end

end
