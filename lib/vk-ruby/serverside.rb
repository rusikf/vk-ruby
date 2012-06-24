# encoding: UTF-8

class VK::Serverside 
  include VK::Core
  include ::Transformer

  attr_accessor :app_secret, :expires_in

  def app_secret
    @app_secret ? @app_secret : VK.const_defined?(:APP_SECRET) ? VK::APP_SECRET : nil
  end

  def settings
    @settings ? @settings : VK.const_defined?(:SETTINGS) ? VK::SETTINGS : 'notify,friends,offline'
  end

  def initialize params = {}
    params.each{|k,v| instance_variable_set(:"@#{k}", v) }
    raise 'undefined application id' unless self.app_id
    raise 'undefined application secret' unless self.app_secret
    transform base_api, self.method(:vk_call)
  end

  def authorize code, auto_save = true
    params = {:client_id => self.app_id, :client_secret => self.app_secret, :code => code}
    response = request(:get, "/oauth/access_token", params)
    raise VK::AuthorizeException.new(response) if response['error']
    response.each{|k,v| instance_variable_set(:"@#{k}", v) } if auto_save
    response
  end
end