class VK::Serverside 
  include VK::Core
  include ::Transformer

  attr_accessor :app_secret

  def initialize(p={})
    p.each{|k,v| instance_variable_set(:"@#{k}", v) }
    raise 'undefined application id' unless @app_id
    raise 'undefined application secret' unless @app_secret
    
    @settings ||= 'notify,friends,offline' 

    transform base_api, self.method(:vk_call)
  end

  def authorize(code, auto_save = true)
    params = {:client_id => @app_id, :client_secret => @app_secret, :code => code}

    response = request :get, "/oauth/access_token", params

    raise VK::AuthorizeException.new(response) if response['error']

    response.each{|k,v| instance_variable_set(:"@#{k}", v) } if auto_save

    response
  end
end