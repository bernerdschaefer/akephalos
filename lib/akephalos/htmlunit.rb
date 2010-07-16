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

java_import "com.gargoylesoftware.htmlunit.WebClient"
java_import "com.gargoylesoftware.htmlunit.util.WebConnectionWrapper"
java_import 'com.gargoylesoftware.htmlunit.HttpMethod'

com.gargoylesoftware.htmlunit.BrowserVersion.setDefault(
  com.gargoylesoftware.htmlunit.BrowserVersion::FIREFOX_3
)
