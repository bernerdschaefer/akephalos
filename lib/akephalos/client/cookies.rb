module Akephalos
  class Client
    # Interface for working with HtmlUnit's CookieManager, providing a basic
    # API for manipulating the cookies in a session.
    class Cookies
      include Enumerable

      # @param [HtmlUnit::CookieManager] cookie manager
      def initialize(cookie_manager)
        @cookie_manager = cookie_manager
      end

      # @param [name] the cookie name
      # @return [Cookie] the cookie with the given name
      # @return [nil] when no cookie is found
      def [](name)
        cookie = @cookie_manager.getCookie(name)
        Cookie.new(cookie) if cookie
      end

      # Clears all cookies for this session.
      def clear
        @cookie_manager.clearCookies
      end

      # Iterator for all cookies in the current session.
      def each
        @cookie_manager.getCookies.each do |cookie|
          yield Cookie.new(cookie)
        end
      end

      # Remove the cookie from the session.
      #
      # @param [Cookie] the cookie to remove
      def delete(cookie)
        @cookie_manager.removeCookie(cookie.native)
      end

      # @return [true, false] whether there are any cookies
      def empty?
        !any?
      end

      class Cookie

        attr_reader :domain, :expires, :name, :path, :value

        # @param [HtmlUnit::Cookie] the cookie
        def initialize(cookie)
          @_cookie = cookie
          @domain = cookie.getDomain
          @expires = cookie.getExpires
          @name = cookie.getName
          @path = cookie.getPath
          @value = cookie.getValue
          @secure = cookie.isSecure
        end

        def secure?
          !!@secure
        end

        # @return [HtmlUnit::Cookie] the native cookie object
        # @api private
        def native
          @_cookie
        end
      end

    end
  end
end
