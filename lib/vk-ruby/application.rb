# Application implementation

class VK::Application
  # includes "VK::Core", "VK::Auth", "VK::Uploading" and "VK::Namespaces"
  # 
  # @!parse include VK::Core
  # @!parse include VK::Auth
  # @!parse include VK::Uploading
  # @!parse include VK::Namespaces

  include VK::Core
  include VK::Auth
  include VK::Uploading
  include VK::Namespaces

  # Initialize a new VK::Application instance
  #
  # @param [Hash] params params for config (VK::Config)
  #
  # @yieldparam config [VK::Config] application instance config
  #
  # @see VK::Config VK::Config
  # @note With VK::Application initializing config params merged with default config.

  def initialize(params = {})
    config.merge! params
    yield(self.config) if block_given?
  end

  create_default_namespaces!
end
