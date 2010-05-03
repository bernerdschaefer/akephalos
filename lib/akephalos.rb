require 'capybara'

module Akephalos
end

require 'akephalos/capybara'

if Object.const_defined? :Cucumber
  require 'akephalos/cucumber'
end
