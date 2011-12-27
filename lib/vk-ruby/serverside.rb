module VK  
  class Serverside 
    include Core
    include Transformer

    attr_accessor :app_secret, :settings

    def initialize(p={})
      p.each{|k,v| instance_variable_set(:"@#{k}", v) }
      raise 'undefined application id' unless @app_id
      raise 'undefined application secret' unless @app_secret
      
      @settings ||= 'notify,friends,offline' 

      transform base_api, self.method(:vk_call)
    end

    def authorize(code = nil, auto_save = true)
      raise VK::VkAuthorizeException.new('undefined code') unless code
      params = {:client_id => @app_id, :client_secret => @app_secret, :code => code}

      result = request({:path => "/oauth/access_token", :params => params })
      raise VK::VkAuthorizeException.new(result) if result['error']

      result.each{|k,v| instance_variable_set(:"@#{k}", v) } if auto_save

      result
    end

  end
end