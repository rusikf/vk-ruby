# encoding: UTF-8

class VK::Application
  include VK::Core
  include VK::Auth
  include VK::Uploading
  include VK::Namespaces

  # A new VK::Application instance.
  def initialize(params = {})
    config.merge! params
    yield(self) if block_given?
  end

  create_default_namespaces!
end
