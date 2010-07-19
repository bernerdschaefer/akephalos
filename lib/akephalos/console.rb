def session
  Capybara.app_host = "http://localhost:3000"
  @session ||= Capybara::Session.new(:Akephalos)
end
alias page session

module Akephalos
  class Console

    def self.start
      require 'irb'

      begin
        require 'irb/completion'
      rescue Exception
        # No readline available, proceed anyway.
      end

      if ::File.exists? ".irbrc"
        ENV['IRBRC'] = ".irbrc"
      end

      IRB.start
    end

  end
end
