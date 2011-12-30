module VK::Executable
  class Api

    def initialize
      transform base_api, self.method(:vk_call)
      transform ext_api,  self.method(:vk_call)
      transform secure_api,  self.method(:vk_call)
    end

    private

    def vk_call(method_name, args)
      action = ['API', method_name].join
      params = ['(', params.to_vkscript, ')'].join if params = args.shift
      [action, params].join('.')
    end

  end  
end