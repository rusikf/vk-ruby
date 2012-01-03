module VK::Executable
  class Method
    include Transformer

    def initialize
      transform base_api,   self.method(:vk_call)
      transform ext_api,    self.method(:vk_call)
      transform secure_api, self.method(:vk_call)
    end

    private

    def vk_call(method_name, args)
      action = ['API', method_name].join('.')
      params = ['(', params.to_vkscript, ')'].join if params = args.shift
      [action, params].join
    end

    [:base, :ext, :secure].each do |name|
      class_eval(<<-EVAL, __FILE__, __LINE__)
        def #{name}_api
          @@#{name}_api ||= YAML.load_file( File.expand_path( File.dirname(__FILE__) + "/../api/#{name}.yml" ))
        end
      EVAL
    end

  end  
end