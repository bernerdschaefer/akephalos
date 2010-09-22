module HtmlUnit
  # Reopen HtmlUnit's HttpMethod class to add convenience methods.
  class HttpMethod

    # Loosely compare HttpMethod with another object, accepting either an
    # HttpMethod instance or a symbol describing the method. Note that :any is a
    # special symbol which will always return true.
    #
    # @param [HttpMethod] other an HtmlUnit HttpMethod object
    # @param [Symbol] other a symbolized representation of an http method
    # @return [true/false]
    def ===(other)
      case other
      when HttpMethod
        super
      when :any
        true
      when :get
        self == self.class::GET
      when :post
        self == self.class::POST
      when :put
        self == self.class::PUT
      when :delete
        self == self.class::DELETE
      end
    end

  end
end
