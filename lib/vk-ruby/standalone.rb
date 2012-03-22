# encoding: UTF-8

class VK::Standalone 
  include VK::Core
  include ::Transformer

  attr_accessor :settings

  def settings
    @settings ? @settings : VK.const_defined?(:SETTINGS) ? VK::SETTINGS : 'notify,friends'
  end

  def initialize(p={})
    p.each{|k,v| instance_variable_set(:"@#{k}", v) }
    raise 'undefined application id' unless self.app_id
    transform base_api, self.method(:vk_call)
    transform ext_api, self.method(:vk_call)
  end
end