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

  YAML.load_file(File.expand_path('../namespaces.yml', __FILE__)).each do |namespace|
    define_method namespace do
      instance_variable_get("@#{ namespace }") ||
      instance_variable_set("@#{ namespace }", VK::Methods.new(namespace, handler))
    end
  end

end
