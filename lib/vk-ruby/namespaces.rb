# API namespaces methods

module VK::Namespaces
  module ClassMethods

    private

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
    
    # Execute VK stored procedure (see {https://vk.com/dev/execute})
    # 
    # @param [Hash] params execute method params
    # @option code [String] VKScript
    #
    # @example Call API method with code param
    #   application.execute code: 'return 1 + 1;' #=> 2
    #
    # @example Call user-stored procedure with arguments
    #   application.execute.user_proc_name a: { b: 1, c: 2} #=> computed result
    #
    # @return servers response
    #
    # @raise [VK::APIError] with API error

    def execute(params = {}, &block)
      if params.empty?
        @execute ||= VK::Methods.new(:execute, handler)
      else
        method_missing(:execute, params, &block)
      end
    end

    private
    
    # @!attribute [r] namespace
    #   @return [String] API namespace name
    attr_reader :namespace

    # @private
    def method_missing(method_name, *args, &block)
      api_method = VK::Utils.camelize(method_name)
      api_full_method = namespace ? [namespace, api_method].join('.') : api_method

      result = handler.call(api_full_method, args.first || {})

      metaclass.send(:define_method, method_name) do |params={}|
        handler.call(api_full_method, params)
      end
      
      metaclass.send(:alias_method, api_method, method_name)

      result
    end

    # @!attribute [r] handler
    #   @return [String] Request handler
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
