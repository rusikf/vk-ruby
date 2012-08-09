require "unicode_utils"

module Faraday
  class Response::ValidateUtf < Response::Middleware

    def initialize(app)
      super(app)
    end

    def call(environment)
      @app.call(environment).on_complete do |env|
        
        if (env[:body] = env[:body].force_encoding('UTF-8')).valid_encoding?        
          env[:body] = env[:body].chars.select{|i| i.valid_encoding?}.join
        end

        env
      end
    end

  end
end

Faraday.register_middleware :response, validate_utf: Faraday::Response::ValidateUtf 