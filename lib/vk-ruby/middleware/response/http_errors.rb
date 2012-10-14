# encoding: UTF-8 

class VK::MW::Response::HttpErrors < Faraday::Response::Middleware

  def call(environment)
    @app.call(environment).on_complete do |env|

      if !env[:response].success?
        fail VK::BadResponseException.new(env[:response])
      end
    end
  end

end