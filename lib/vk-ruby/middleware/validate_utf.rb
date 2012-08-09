require "unicode_utils"

module Faraday
  class Response::ValidateUtf < Response::Middleware

    def initialize(app)
      super(app)
    end

    def call(environment)
      @app.call(environment).on_complete do |env|
        puts env[:body] = env[:body].force_encoding('UTF-8').gsub(/[^\x00-\x7F]/,'').chars.select{|i| i.valid_encoding?}.join
        env
      end
    end

  end
end

Faraday.register_middleware :response, validate_utf: Faraday::Response::ValidateUtf 