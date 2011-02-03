require 'spec_helper'

describe Capybara::Driver::Akephalos do

  describe "visiting a page with a javascript error" do
    context "with script validation enabled" do

      let(:driver) do
        Capybara::Driver::Akephalos.new(Application)
      end

      it "raises an exception" do
        running do
          driver.visit "/page_with_javascript_error"
        end.should raise_error
      end

    end

    context "with script validation disabled" do

      let(:driver) do
        Capybara::Driver::Akephalos.new(
          Application,
          :validate_scripts => false
        )
      end

      it "ignores the error" do
        running do
          driver.visit "/page_with_javascript_error"
        end.should_not raise_error
      end

    end
  end

end
