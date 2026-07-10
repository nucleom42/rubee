module Rubee
  class CookieSamesiteMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)

      cookie_header = headers["Set-Cookie"] || headers["set-cookie"]
      header_key = headers["Set-Cookie"] ? "Set-Cookie" : "set-cookie"

      if cookie_header
        headers[header_key] = patch_cookies(cookie_header)
      end

      [status, headers, body]
    end

    private

    def patch_cookies(cookies)
      is_dev = ENV['RACK_ENV'] == 'development' || ENV['RACK_ENV'].nil?

      cookies.split("\n").map do |cookie|
        cookie = cookie.gsub(/;\s*secure/i, "") if is_dev

        unless cookie.downcase.include?("samesite")
          cookie += "; SameSite=Lax"
        end

        cookie
      end.join("\n")
    end
  end
end
