# encoding: UTF-8

module VK::Namespaces

  module ClassMethods
    def create_default_namespaces!
      default_namespaces.each do |namespace|
        define_method namespace do
          instance_variable_get("@#{ namespace }") ||
          instance_variable_set("@#{ namespace }", VK::Methods.new(namespace, handler))
        end
      end
    end

    def default_namespaces
      @names ||= YAML.load_file(File.expand_path('../namespaces.yml', __FILE__))
    end
  end

  module InstanceMethods
    attr_reader :namespace, :handler

    def method_missing(method_name, *args, &block)
      api_method = VK::Utils.camelize(method_name)
      api_full_method = @namespace ? [@namespace, api_method].join('.') : api_method

      result = handler.call(api_full_method, args.first || {})

      metaclass.send(:define_method, method_name) do |params={}|
        handler.call(api_full_method, params)
      end
      
      metaclass.send(:alias_method, api_method, method_name)

      result
    end

    def execute(params = {}, &block)
      if params.empty?
        @execute ||= VK::Methods.new(:execute, handler)
      else
        method_missing(:execute, params, &block)
      end
    end

    private

    def handler
      @handler ||= self.method(:vk_call)
    end

    def metaclass
      class << self; self; end
    end
  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end
