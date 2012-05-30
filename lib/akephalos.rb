# **Akephalos** is a cross-platform Ruby interface for *HtmlUnit*, a headless
# browser for the Java platform.
#
# The only requirement is that a Java runtime is available.
#
require 'java' if RUBY_PLATFORM == 'java'
require 'pathname'

module Akephalos
  BIN_DIR = Pathname(__FILE__).expand_path.dirname.parent + 'bin'
end

require 'akephalos/client'

if Object.const_defined? :Capybara
  require 'capybara'
  
  module Capybara
    module Driver
      autoload :Akephalos, 'akephalos/capybara'
    end
  end

  Capybara.register_driver :akephalos do |app|
    Capybara::Driver::Akephalos.new(app)
  end
end

Capybara.register_driver :akephalos do |app|
  Capybara::Driver::Akephalos.new(app)
end
