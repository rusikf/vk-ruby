module VK
  class Standalone 
    include Core
    include Transformer

    attr_accessor :settings

    def initialize(p={})
      p.each{|k,v| instance_variable_set(:"@#{k}", v) }
      raise 'undefined application id' unless @app_id

      @settings ||= 'notify,friends'

      transform base_api, self.method(:vk_call)
      transform ext_api, self.method(:vk_call)
    end

  end
end