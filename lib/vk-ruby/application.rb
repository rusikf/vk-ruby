# encoding: UTF-8

class VK::Application
  include VK::Core
  extend ::Configurable

  # The duration of the token after authorization
  attr_accessor :expires_in

  # A new VK::Application instance.
  def initialize(params = {})
    params.each { |k,v| send("#{k}=", v) }
  end

end
