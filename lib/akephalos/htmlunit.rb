require "pathname"
require "java"

dependency_directory = $:.detect { |path| Dir[File.join(path, 'htmlunit/htmlunit-*.jar')].any? }

raise "Could not find htmlunit/htmlunit-VERSION.jar in load path:\n  [ #{$:.join(",\n    ")}\n  ]" unless dependency_directory

Dir[File.join(dependency_directory, "htmlunit/*.jar")].each do |jar|
  require jar
end

java.lang.System.setProperty("org.apache.commons.logging.Log", "org.apache.commons.logging.impl.SimpleLog")
java.lang.System.setProperty("org.apache.commons.logging.simplelog.defaultlog", "fatal")
java.lang.System.setProperty("org.apache.commons.logging.simplelog.showdatetime", "true")

# Container module for com.gargoylesoftware.htmlunit namespace.
module HtmlUnit
  java_import "com.gargoylesoftware.htmlunit.BrowserVersion"
  java_import "com.gargoylesoftware.htmlunit.History"
  java_import "com.gargoylesoftware.htmlunit.HttpMethod"
  java_import "com.gargoylesoftware.htmlunit.NicelyResynchronizingAjaxController"
  java_import "com.gargoylesoftware.htmlunit.SilentCssErrorHandler"
  java_import "com.gargoylesoftware.htmlunit.WebClient"
  java_import "com.gargoylesoftware.htmlunit.WebResponseData"
  java_import "com.gargoylesoftware.htmlunit.WebResponseImpl"

  # Container module for com.gargoylesoftware.htmlunit.util namespace.
  module Util
    java_import "com.gargoylesoftware.htmlunit.util.NameValuePair"
    java_import "com.gargoylesoftware.htmlunit.util.WebConnectionWrapper"
  end

  # Disable history tracking
  History.field_reader :ignoreNewPages_
end
