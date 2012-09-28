# encoding: UTF-8

class VK::Serverside < VK::Application

  # A new VK::Serverside application.
  def initialize(params={})
    VK::Utils.deprecate "VK::Serverside is deprecate, please use VK::Application"
    super params
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
    raise 'undefined application redirect_url' unless self.app_secret

    params = {host: 'https://oauth.vk.com',
              client_id: self.app_id,
              client_secret: self.app_secret,
              code: code,
              redirect_uri: self.redirect_uri,
              verb: :get}

    response = request("/access_token", params)

    raise VK::AuthorizeException.new(response) if response.body['error']

    response.body.each{|k,v| instance_variable_set(:"@#{k}", v) } if auto_save

    response.body
  end
end