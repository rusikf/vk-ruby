# encoding: UTF-8

class VK::Application
  include VK::Core
  extend ::Configurable

  # The duration of the token after authorization
  attr_accessor :expires_in

   # A new VK::Application instan.
  def initialize(params = {})
    params.each{|k,v| instance_variable_set(:"@#{k}", v) }
    init_namespaces(NAMESPACES)
  end

  # Authorization (getting the access token by code)
  # {http://vk.com/developers.php?oid=-1&p=%D0%90%D0%B2%D1%82%D0%BE%D1%80%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D1%8F_%D1%81%D0%B0%D0%B9%D1%82%D0%BE%D0%B2 Read more}
  #
  # @param [String] param - is param required from getting access token.
  # @param [Hash] params configurable options request. if you do not pass the option that will be used by the same name attribute.
  # @option params [Boolean] :save indicator that you want to save the returns parameters. Default `true`.
  # @option params [Symbol]  :type authorization type `:serverside` or `:secure`.
  # @option params [Symbol]  :code code param required for serverside authorization. Default `serverside`.
  #
  # @raise [VK::AuthorizeException] if vk.com return json with key error.

  def authorize(params = {})
    raise 'undefined application id'     unless self.app_id
    raise 'undefined application secret' unless self.app_secret

    params[:save].nil? ? (params[:save] = true) : (params[:save] = false)
    params[:type] ||= :serverside

    options = case params[:type]
    when :serverside
      {host: 'https://oauth.vk.com',
      client_id: self.app_id,
      client_secret: self.app_secret,
      code: params[:code],
      verb: :get}
    when :secure
      {host: 'https://oauth.vk.com',
      client_id: self.app_id,
      client_secret: self.app_secret,
      grant_type: :client_credentials,
      verb: :get}
    end

    response = request("/access_token", options)

    raise VK::AuthorizeException.new(response) if response.body['error']

    response.body.each{|k,v| instance_variable_set(:"@#{k}", v) } if params[:save]

    response.body
  end

end
