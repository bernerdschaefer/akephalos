if RUBY_PLATFORM != "java"
  require 'akephalos/remote_client'
  Akephalos::Client = Akephalos::RemoteClient
else
  require 'akephalos/htmlunit'
  require 'akephalos/page'
  require 'akephalos/node'

  module Akephalos
    class Client
      attr_reader :page

      def initialize
        @_client = WebClient.new

        @_client.setAjaxController(com.gargoylesoftware.htmlunit.NicelyResynchronizingAjaxController.new)

        listener = Class.new do
          include com.gargoylesoftware.htmlunit.WebWindowListener

          def initialize(client)
            @client = client
          end

          def webWindowClosed(event)
          end

          def webWindowContentChanged(event)
            @client.page = event.getNewPage
            if latch = Thread.current[:latch]
              latch.countDown
              Thread.current[:latch] = nil
            end
          end
        end

        @_client.addWebWindowListener(listener.new(self))
        @_client.setCssErrorHandler(com.gargoylesoftware.htmlunit.SilentCssErrorHandler.new)
      end

      def visit(url)
        self.class.wait_for_result do
          @_client.getPage(url)
        end
      end

      def page=(_page)
        if @page != _page
          @page = Page.new(_page)
        end
        @page
      end

      def self.wait_for_result(timeout = 3)
        latch = java.util.concurrent.CountDownLatch.new(1)
        Thread.new do
          Thread.current[:latch] = latch
          yield
        end.join
        start = Time.now
        latch.await(timeout, java.util.concurrent.TimeUnit::SECONDS)
      end

    end
  end
end
