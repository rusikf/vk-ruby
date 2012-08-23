# encoding: UTF-8

class VK::Secure
  include VK::Core
  include Transformer

  extend ::VK::Configurable

  attr_configurable :app_secret

  def app_secret
    @app_secret ? @app_secret : VK.const_defined?(:APP_SECRET) ? VK::APP_SECRET : nil
  end

  def initialize(params)
    params.each{|k,v| instance_variable_set(:"@#{k}", v)}

    raise 'undefined application id' unless self.app_id
    raise 'undefined application secret' unless self.app_secret

    transform secure_api, self.method(:vk_call)
  end

  def authorize(auto_save = true)
    params = {host: 'https://oauth.vk.com',
              client_id: self.app_id,
              client_secret: self.app_secret,
              grant_type: :client_credentials,
              verb: :get}

    response = request("/access_token", params)

    raise VK::AuthorizeException.new(response) if response.body['error']

    response.body.each{|k,v| instance_variable_set(:"@#{k}", v) } if auto_save

    response.body
  end
end