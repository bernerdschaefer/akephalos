require 'spec_helper'

describe "Filters" do
  before do
    @session = Capybara::Session.new(:akephalos, TestApp)
  end

  context "with no filter" do
    it "returns the page's source" do
      @session.visit "/"
      @session.source.should == "Hello world!"
    end
  end

  context "with a filter" do
    after { Akephalos.filters.clear }

    it "returns the filter's source" do
      Akephalos.filter :get, %r{.*}, :body => "Howdy!"
      @session.visit "/"
      @session.source.should == "Howdy!"
    end
  end
end
