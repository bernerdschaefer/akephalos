require "pathname"
require "drb/drb"
require "akephalos/client"

class NameError::Message
  def _dump
    to_s
  end
end

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

module Akephalos
  class Server
    def self.start!(socket_file)
      client = Client.new
      DRb.start_service("drbunix://#{socket_file}", client)
      DRb.thread.join
    end
  end
end
