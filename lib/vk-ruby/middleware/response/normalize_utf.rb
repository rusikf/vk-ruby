require "unicode_utils"

module Faraday
  class Response::NormalizeUtf < Response::Middleware

    def initialize(app)
      super(app)
    end

    def call(environment)
      @app.call(environment).on_complete do |env|
        env[:body] = UnicodeUtils.nfkd(env[:body])
        env
      end
    end

  end
end

Faraday.register_middleware :response, normalize_utf: Faraday::Response::NormalizeUtf