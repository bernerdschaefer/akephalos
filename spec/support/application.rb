class Application < TestApp
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

  get '/user_agent_detection' do
    request.user_agent
  end

  get '/app_domain_detection' do
    "http://#{request.host_with_port}/app_domain_detection"
  end

  get '/page_with_javascript_error' do
    <<-HTML
  <head>
    <script type="text/javascript">
      $() // is not defined
    </script>
  </head>
  <body>
  </body>
   HTML
  end

  get '/ie_test' do
    <<-HTML
  <body>
  <!--[if IE 6]>
  This is for InternetExplorer6
  <![endif]-->
  <!--[if IE 7]>
  This is for InternetExplorer7
  <![endif]-->
  <!--[if IE 8]>
  This is for InternetExplorer8
  <![endif]-->
  </body>
    HTML
  end
end

if $0 == __FILE__
  Rack::Handler::Mongrel.run Application, :Port => 8070
end

