require 'spec_helper'

describe Capybara::Driver::Akephalos do

  before do
    @driver = Capybara::Driver::Akephalos.new(TestApp)
  end

  it_should_behave_like "driver"
  it_should_behave_like "driver with javascript support"
  it_should_behave_like "driver with header support"

end
