# encoding: UTF-8 

class VK::MW::Response::ApiErrors < Faraday::Response::Middleware

  def call(environment)
    @app.call(environment).on_complete do |env|
      response = env[:response]
      
      if response.body.has_key?('error')
        if env[:url].host == 'oauth.vk.com'
          fail VK::AuthorizeException.new response.body
        else
          method_name = env[:url].path.split('/').last.inspect
          fail VK::ApiException.new(method_name, response.body)
        end
      end
    end
  end

end