# encoding: UTF-8

class VK::Serverside
  include VK::Core
  include Transformer

  extend ::Configurable

  # The duration of the token after authorization
  attr_accessor :expires_in

  # Application ID that will be used to make authorize request.
  # @method app_secret

  attr_configurable :app_secret

  # Application settings(scope) that will be used to make authorize request.
  # Default `'notify,friends,offline'`
  # @method settings
  #
  # {http://vk.com/developers.php?oid=-1&p=%D0%9F%D1%80%D0%B0%D0%B2%D0%B0_%D0%B4%D0%BE%D1%81%D1%82%D1%83%D0%BF%D0%B0_%D0%BF%D1%80%D0%B8%D0%BB%D0%BE%D0%B6%D0%B5%D0%BD%D0%B8%D0%B9 Read more.}

  attr_configurable :settings, default: 'notify,friends,offline'

  # A new VK::Serverside application.
  def initialize(params = {})
    params.each{|k,v| instance_variable_set(:"@#{k}", v) }

    transform base_api, self.method(:vk_call)
  end

  # Authorization (getting the access token by code)
  # {http://vk.com/developers.php?oid=-1&p=%D0%90%D0%B2%D1%82%D0%BE%D1%80%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D1%8F_%D1%81%D0%B0%D0%B9%D1%82%D0%BE%D0%B2 Read more}
  #
  # @param [String] code - is param required from getting access token.
  # @param [TrueClass|FalseClass] auto_save - indicator that you want to save the returns parameters. Default `true`.
  #
  # @raise if app_id attribute is nil.
  # @raise if app_secret attribute is nil.
  # @raise [VK::AuthorizeException] if vk.com return json with key error.

  def authorize(code, auto_save = true)
    raise 'undefined application id'     unless self.app_id
    raise 'undefined application secret' unless self.app_secret

    params = {host: 'https://oauth.vk.com',
              client_id: self.app_id,
              client_secret: self.app_secret,
              code: code,
              verb: :get}

    response = request("/access_token", params)

    raise VK::AuthorizeException.new(response) if response.body['error']

    response.body.each{|k,v| instance_variable_set(:"@#{k}", v) } if auto_save

    response.body
  end
end