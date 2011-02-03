require 'spec_helper'

describe Capybara::Driver::Akephalos do

  let(:session) { Capybara::Session.new(:akephalos, Application) }

  before do
    @original_driver = Capybara.drivers.delete(:akephalos)
  end

  after do
    Capybara.drivers[:akephalos] = @original_driver
  end

  describe "visiting a page with browser specific content" do
    context "when in IE6 mode" do
      before do
        Capybara.register_driver :akephalos do |app|
          Capybara::Driver::Akephalos.new(app, :browser => :ie6)
        end
      end

      it "renders IE6 content" do
        session.visit "/ie_test"
        session.should have_content("InternetExplorer6")
      end

      it "does not render other content" do
        session.visit "/ie_test"
        session.should_not have_content("InternetExplorer7")
      end
    end

    context "when in IE7 mode" do
      before do
        Capybara.register_driver :akephalos do |app|
          Capybara::Driver::Akephalos.new(app, :browser => :ie7)
        end
      end

      it "renders IE7 content" do
        session.visit "/ie_test"
        session.should have_content("InternetExplorer7")
      end

      it "does not render other content" do
        session.visit "/ie_test"
        session.should_not have_content("InternetExplorer6")
      end
    end

    context "when in Firefox mode" do
      before do
        Capybara.register_driver :akephalos do |app|
          Capybara::Driver::Akephalos.new(app, :browser => :firefox_3_6)
        end
      end

      it "does not render IE content" do
        session.visit "/ie_test"
        session.should_not have_content("InternetExplorer")
      end
    end
  end

end
