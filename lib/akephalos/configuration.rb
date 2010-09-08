module Akephalos

  @configuration = {}

  class << self
    attr_accessor :configuration
  end

  module Filters
    def filters
      configuration[:filters] ||= []
    end

    def filter(method, regex, options = {})
      regex = Regexp.new(Regexp.escape(regex)) if regex.is_a?(String)
      filters << {:method => method, :filter => regex, :status => 200, :body => "", :headers => {}}.merge!(options)
    end
  end

  extend Filters
end
