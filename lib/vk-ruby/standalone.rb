# encoding: UTF-8

class VK::Standalone < VK::Application

  # A new VK::Standalone application.
  def initialize(params={})
    VK::Utils.deprecate "VK::Standalone is deprecate, please use VK::Application"
    super params
  end

end