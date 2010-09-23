require 'spec_helper'

describe Capybara::Driver::Akephalos do

  let(:driver) { Capybara::Driver::Akephalos.new(Application) }
  after do
    driver.user_agent = :default
    driver.reset!
  end

  describe "#user_agent=" do
    context "when given :default" do
      it "resets the user agent" do
        driver.user_agent = "something else"
        driver.user_agent = :default
        driver.user_agent.should =~ /Firefox/
      end
    end

    context "when given a string" do
      it "sets the user agent" do
        new_user_agent = "iPhone user agent"
        driver.user_agent = new_user_agent
        driver.user_agent.should == new_user_agent
      end
    end
  end

  describe "#user_agent" do
    context "with the default set" do
      it "returns the default user agent string" do
        driver.user_agent.should =~ /Firefox/
      end
    end
  end

  context "when requesting a page" do
    context "with no user agent set" do
      it "sends the default header" do
        driver.visit "/user_agent_detection"
        driver.body.should include("Firefox")
      end
    end

    context "with a user agent set" do
      it "sends the given user agent header" do
        driver.user_agent = "iPhone user agent"
        driver.visit "/user_agent_detection"
        driver.body.should include("iPhone user agent")
      end

      context "when resetting back to default" do
        it "sends the default user agent header" do
          driver.user_agent = :default
          driver.visit "/user_agent_detection"
          driver.body.should include("Firefox")
        end
      end
    end

  end

end
