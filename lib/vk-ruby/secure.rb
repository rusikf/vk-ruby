module VK  
  class Secure
    include Core
    include Transformer

    attr_reader :app_secret

    def initialize(p={})
      p.each{|k,v| instance_variable_set(:"@#{k}", v) }
      raise 'undefined application id' unless @app_id
      raise 'undefined application secret' unless @app_secret
      transform secure_api, self.method(:vk_call)
    end

    def authorize(auto_save = true)
      prms = {:client_id => @app_id, :client_secret => @app_secret, :grant_type => :client_credentials}
      
      result = JSON.parse(request({:path => "/oauth/access_token", :params => prms }).body)
      raise VK::VkAuthorizeException.new(result) if result['error']
      result.each{|k,v| instance_variable_set(:"@#{k}", v) } if auto_save

      result
    end
  end
end