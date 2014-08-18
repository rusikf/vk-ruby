# CLI context

class VK::IRB::Context < VK::Application

  attr_reader :config

  def initialize(config)
    @config = config
  end
end
