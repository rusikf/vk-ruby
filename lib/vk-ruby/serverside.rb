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
  end
end