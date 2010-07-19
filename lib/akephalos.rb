# **Akephalos** is a cross-platform Ruby interface for *HtmlUnit*, a headless
# browser for the Java platform.
#
# The only requirement is that a Java runtime is available.
#
require 'java' if RUBY_PLATFORM == 'java'
require 'capybara'

module Akephalos
  BIN_DIR = Pathname(__FILE__).expand_path.dirname.parent + 'bin'
end

require 'akephalos/client'
require 'akephalos/capybara'

if Object.const_defined? :Cucumber
  require 'akephalos/cucumber'
end
