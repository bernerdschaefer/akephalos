module Akephalos

  @configuration = {}

  class << self
    # @return [Hash] the configuration
    attr_accessor :configuration
  end

  module Filters
    # @return [Array] all defined filters
    def filters
      configuration[:filters] ||= []
    end

    # Defines a new filter to be tested by Akephalos::Filter when executing
    # page requests. An HTTP method and a regex or string to match against the
    # URL are required for defining a filter.
    #
    # You can additionally pass the following options to define how the
    # filtered request should respond:
    #
    #   :status       (defaults to 200)
    #   :body         (defaults to "")
    #   :headers      (defaults to {})
    #
    # If we define a filter with no additional options, then, we will get an
    # empty HTML response:
    #
    #   Akephalos.filter :post, "http://example.com"
    #   Akephalos.filter :any, %r{http://.*\.com}
    #
    # If you instead, say, wanted to simulate a failure in an external system,
    # you could do this:
    #
    #   Akephalos.filter :post, "http://example.com",
    #     :status => 500, :body => "Something went wrong"
    #
    # @param [Symbol] method the HTTP method to match
    # @param [RegExp, String] regex URL matcher
    # @param [Hash] options response values
    def filter(method, regex, options = {})
      regex = Regexp.new(Regexp.escape(regex)) if regex.is_a?(String)
      filters << {:method => method, :filter => regex, :status => 200, :body => "", :headers => {}}.merge!(options)
    end
  end

  extend Filters
end
