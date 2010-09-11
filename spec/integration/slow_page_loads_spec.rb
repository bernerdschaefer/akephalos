require 'spec_helper'

class SlowApp < TestApp
  get '/slow_page' do
    sleep 1
    "<p>Loaded!</p>"
  end

  get '/slow_ajax_load' do
    <<-HTML
  <head>
    <meta http-equiv="Content-type" content="text/html; charset=utf-8"/>
    <title>with_js</title>
    <script src="/jquery.js" type="text/javascript" charset="utf-8"></script>
    <script type="text/javascript">
      $(function() {
       $('#ajax_load').click(function() {
         $('body').load('/slow_page');
         return false;
       });
      });
    </script>
  </head>
  <body>
    <a href="#" id="ajax_load">Click me</a>
  </body>
   HTML
  end
end

if $0 == __FILE__
  if __FILE__ == $0
    Rack::Handler::Mongrel.run SlowApp, :Port => 8070
  end
end

describe Capybara::Session do
  context 'with akephalos driver' do

    before do
      @session = Capybara::Session.new(:akephalos, SlowApp)
    end

    context "slow page load" do
      it "should wait for the page to finish loading" do
        @session.visit('/slow_page')
        @session.current_url.should include('/slow_page')
      end
    end

    context "slow ajax load" do
      it "should wait for ajax to load" do
        @session.visit('/slow_ajax_load')
        @session.click_link('Click me')
        @session.should have_xpath("//p[contains(.,'Loaded!')]")
      end
    end

  end
end

