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
require "htmlunit-2.7.jar"
require "htmlunit-core-js-2.7.jar"
require "nekohtml-1.9.14.jar"
require "sac-1.3.jar"
require "serializer-2.7.1.jar"
require "xalan-2.7.1.jar"
require "xercesImpl-2.9.1.jar"
require "xml-apis-1.3.04.jar"

logger = org.apache.commons.logging.LogFactory.getLog('com.gargoylesoftware.htmlunit') 
logger.getLogger().setLevel(java.util.logging.Level::SEVERE)

java_import "com.gargoylesoftware.htmlunit.WebClient"

com.gargoylesoftware.htmlunit.BrowserVersion.setDefault(
    com.gargoylesoftware.htmlunit.BrowserVersion::FIREFOX_3
)
