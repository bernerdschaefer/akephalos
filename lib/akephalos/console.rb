# Begin a new Capybara session, by default connecting to localhost on port
# 3000.
def session
  Capybara.app_host ||= "http://localhost:3000"
  @session ||= Capybara::Session.new(:akephalos)
end
alias page session

module Akephalos
  # Simple class for starting an IRB session.
  class Console

    # Start an IRB session. Tries to load irb/completion, and also loads a
    # .irbrc file if it exists.
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
