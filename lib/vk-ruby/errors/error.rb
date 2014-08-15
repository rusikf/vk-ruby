# Error implementation

class VK::Error < StandardError
  extend Forwardable

  def initialize(env)
    @env = env
  end
end