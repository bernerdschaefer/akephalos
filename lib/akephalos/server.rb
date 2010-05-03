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
  def cleanup!
    exit
  end

  def page
    @page = getCurrentWindow.getEnclosedPage
  end
end

class HtmlPage
  def find(selector)
    nodes = getByXPath(selector)
    (@nodes ||= []).push(*nodes)
    nodes
  end
end

module Akephalos
  class Server
    def self.start!
      puts "Starting Akephalos::Server"
      client = WebClient.new
      DRb.start_service("drbunix:///tmp/htmlunit.sock", client)
      DRb.thread.join
    end
  end
end
