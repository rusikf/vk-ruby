module VK::Executable

  class Variables

    def initialize
      @vars = {}
    end

    private 

    def method_missing(method_name, *argv)
      if method =~ /\w=/
        @vars[method_name] = argv.shift
      else
        super argv
      end
    end

  end

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