module VK::Executable
  class Api
    def initialize
      transform base_api, self.method(:vk_call)
      transform ext_api,  self.method(:vk_call)
    end

    private

    def vk_call(method_name, *params)
      VK::Chain.new method_name, params
    end
  end
  
end