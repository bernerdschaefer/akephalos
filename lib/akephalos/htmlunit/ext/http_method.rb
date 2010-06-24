class HttpMethod
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
