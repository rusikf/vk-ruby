# encoding: UTF-8

class VK::Application
  include VK::Core
  extend ::Configurable

  # The duration of the token after authorization
  attr_accessor :expires_in

  # A new VK::Application instan.
  def initialize(params = {})
    params.each{|k,v| instance_variable_set(:"@#{k}", v) }
  end

end
