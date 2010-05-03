require "pathname"
require "java"

$:.unshift((Pathname(__FILE__).dirname + "../../src").expand_path)
require "commons-codec-1.4.jar"
require "commons-collections-3.2.1.jar"
require "commons-httpclient-3.1.jar"
require "commons-io-1.4.jar"
require "commons-lang-2.4.jar"
require "commons-logging-1.1.1.jar"
require "cssparser-0.9.5.jar"
require "htmlunit-2.6.jar"
require "htmlunit-core-js-2.6.jar"
require "nekohtml-1.9.13.jar"
require "sac-1.3.jar"
require "serializer-2.7.1.jar"
require "xalan-2.7.1.jar"
require "xercesImpl-2.9.1.jar"
require "xml-apis-1.3.04.jar"

java_import 'java.io.StringWriter'
java_import 'java.io.PrintWriter'
java_import "com.gargoylesoftware.htmlunit.WebClient"
java_import "com.gargoylesoftware.htmlunit.html.HtmlPage"

com.gargoylesoftware.htmlunit.BrowserVersion.setDefault(
    com.gargoylesoftware.htmlunit.BrowserVersion::FIREFOX_3
)

require Pathname(__FILE__).dirname + "htmlunit/html_element"
require Pathname(__FILE__).dirname + "htmlunit/html_page"
require Pathname(__FILE__).dirname + "htmlunit/html_select"
require Pathname(__FILE__).dirname + "htmlunit/web_client"
