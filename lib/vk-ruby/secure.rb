# encoding: UTF-8

class VK::Secure
  include VK::Core
  include Transformer

  extend ::Configurable

  # Application secret that will be used to make authorize request.
  # @method app_secret

  attr_configurable :app_secret

  # A new VK::Secure application.
  def initialize(params = {})
    params.each{|k,v| instance_variable_set(:"@#{k}", v)}

    transform secure_api, self.method(:vk_call)
  end

  # Authorization (getting the access token by code)
  # Read more {http://vk.com/developers.php?oid=-1&p=%D0%90%D0%B2%D1%82%D0%BE%D1%80%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D1%8F_%D1%81%D0%B5%D1%80%D0%B2%D0%B5%D1%80%D0%B0_%D0%BF%D1%80%D0%B8%D0%BB%D0%BE%D0%B6%D0%B5%D0%BD%D0%B8%D1%8F Read more}
  #
  # @param [Boolean] auto_save - indicator that you want to save the parameters returns. Default `true`.
  #
  # @raise if app_id attribute is nil.
  # @raise if app_secret attribute is nil.
  # @raise [VK::AuthorizeException] if vk.com return json with key error.

  def authorize(auto_save = true)
    raise 'undefined application id'     unless self.app_id
    raise 'undefined application secret' unless self.app_secret

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