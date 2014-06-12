# encoding: UTF-8

class VK::Methods
  include VK::Namespaces

  def initialize(namespace, handler)
    @namespace = namespace
    @handler = handler
  end
end