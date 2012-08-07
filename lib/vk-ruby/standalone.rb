# encoding: UTF-8

class VK::Standalone 
  include VK::Core
  include Transformer

  extend ::VK::Configurable

  attr_accessor :settings, :expires_in

  attr_configurable :settings, default: 'notify,friends'

  def initialize(params={})
    params.each{|k,v| instance_variable_set(:"@#{k}", v) }

    raise 'undefined application id' unless self.app_id
    
    transform base_api, self.method(:vk_call)
    transform ext_api, self.method(:vk_call)
  end
end