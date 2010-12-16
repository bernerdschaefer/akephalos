require 'cucumber'
require 'capybara/cucumber'

Before('@akephalos') do
  Capybara.current_driver = :akephalos
end

