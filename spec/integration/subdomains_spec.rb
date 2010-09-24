require 'spec_helper'

describe Capybara::Driver::Akephalos do

  let(:driver) { Capybara::Driver::Akephalos.new(Application) }
  after do
    Capybara.app_host = nil
    driver.reset!
  end

  context "when changing Capybara.app_host" do
    it "defaults app_host settings" do
      url = driver.rack_server.url("/app_domain_detection")
      driver.visit "/app_domain_detection"
      driver.body.should include(url)
      driver.current_url.should == url
    end

    it "respects the app_host setting" do
      url = "http://smackaho.st:#{driver.rack_server.port}/app_domain_detection"
      Capybara.app_host = "http://smackaho.st:#{driver.rack_server.port}"
      driver.visit "/app_domain_detection"
      driver.body.should include(url)
      driver.current_url.should == url
    end

    it "allows changing app_host multiple times" do
      url = "http://sub1.smackaho.st:#{driver.rack_server.port}/app_domain_detection"
      Capybara.app_host = "http://sub1.smackaho.st:#{driver.rack_server.port}"
      driver.visit "/app_domain_detection"
      driver.body.should include(url)
      driver.current_url.should == url

      url = "http://sub2.smackaho.st:#{driver.rack_server.port}/app_domain_detection"
      Capybara.app_host = "http://sub2.smackaho.st:#{driver.rack_server.port}"
      driver.visit "/app_domain_detection"
      driver.body.should include(url)
      driver.current_url.should == url
    end
  end

end
