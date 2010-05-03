require "pathname"
require "drb/drb"
require Pathname(__FILE__).expand_path.dirname + "htmlunit"

[
  java.net.URL,
  java.util.List,
  com.gargoylesoftware.htmlunit.html.DomNode,
  com.gargoylesoftware.htmlunit.html.DomElement,
  com.gargoylesoftware.htmlunit.html.HtmlAnchor,
  com.gargoylesoftware.htmlunit.html.HtmlElement,
  com.gargoylesoftware.htmlunit.html.HtmlPage,
  org.w3c.dom.Node,
  org.w3c.dom.NamedNodeMap,
  com.gargoylesoftware.htmlunit.WebClient,
  com.gargoylesoftware.htmlunit.WebResponse,
  com.gargoylesoftware.htmlunit.WebRequestSettings
].each { |klass| klass.send(:include, DRbUndumped) }

class WebClient
  def page
    @page = getCurrentWindow.getEnclosedPage
  end
end

class HtmlPage
  def find(selector)
    @present_nodes = getByXPath(selector).to_a
    (@nodes ||= []).push(*@present_nodes)
    @present_nodes
  end
end

class HtmlSubmitInput
  def click
    super
  rescue => e
    puts e
    puts e.backtrace.join("\n")
  end
end

module Akephalos
  class Server
    def self.start!(socket_file)
      client = WebClient.new
      client.setCssErrorHandler(com.gargoylesoftware.htmlunit.SilentCssErrorHandler.new)
      DRb.start_service("drbunix://#{socket_file}", client)
      DRb.thread.join
    end
  end
end
