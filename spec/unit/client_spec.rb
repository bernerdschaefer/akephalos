require 'spec_helper'

describe Akephalos::Client, :platform => :jruby do

  context "browser version" do

    it "defaults to Firefox 3.6" do
      client = Akephalos::Client.new
      client.browser_version.should ==
        HtmlUnit::BrowserVersion::FIREFOX_3_6
    end

    it "can be configured in the initializer" do
      client = Akephalos::Client.new(:browser => :ie6)
      client.browser_version.should ==
        HtmlUnit::BrowserVersion::INTERNET_EXPLORER_6
    end

    it "configures HtmlUnit" do
      client = Akephalos::Client.new(:browser => :ie7)

      client.send(:client).getBrowserVersion.should ==
        HtmlUnit::BrowserVersion::INTERNET_EXPLORER_7
    end

  end

  context "script validation" do

    it "defaults to raising errors on script execution" do
      Akephalos::Client.new.validate_scripts?.should be_true
    end

    it "can be configured not to raise errors on script execution" do
      Akephalos::Client.new(
        :validate_scripts => false
      ).validate_scripts?.should be_false
    end

    it "configures HtmlUnit" do
      client = Akephalos::Client.new(:validate_scripts => false)

      client.send(:client).isThrowExceptionOnScriptError.should be_false
    end

  end

end
