module VK  
  class Secure
    include Core
    include Transformer

    attr_reader :app_secret

    def initialize(p={})
      p.each{|k,v| instance_variable_set(:"@#{k}", v) }
      raise 'undefined application id' unless @app_id
      raise 'undefined application secret' unless @secret
      transform secure_api, self.method(:vk_call)
    end
  end
end