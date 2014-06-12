# encoding: UTF-8 

class VK::MW::HttpErrors < Faraday::Response::Middleware

  def call(environment)
    @app.call(environment).on_complete do |env|
      if not env.success?
        fail VK::BadResponse.new(env)
      end
    end
  end

end