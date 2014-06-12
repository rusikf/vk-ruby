# encoding: UTF-8

module VK::Namespaces

  attr_reader :namespace, :handler

  def method_missing(method_name, *args, &block)
    api_method = VK::Utils.camelize(method_name)
    api_full_method = @namespace ? [@namespace, api_method].join('.') : api_method

    result = handler.call(api_full_method, args.first || {})

    # cache methods
    metaclass.send(:define_method, method_name) do |params={}|
      handler.call(api_full_method, params)
    end
    
    metaclass.send(:alias_method, api_method, method_name)

    result
  end

  private

  def handler
    @handler ||= self.method(:vk_call)
  end

  def metaclass
    class << self; self; end
  end
  
end