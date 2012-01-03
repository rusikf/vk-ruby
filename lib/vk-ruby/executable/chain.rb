module VK::Executable
  class Chain

    def initialize
      @vars = []
      @chain = []
      @api = VK::Executable::Api.new
    end

    def var
      VK::Executable::Variable.new(@vars)
    end

    def api
      @api
    end

    def to_vkscript
      @chain.join
    end

    private 

    def method_missing(method_name, *argv)
      if attribute_name = method_name[/(\w+)?=/,1]
        @vars[attribute_name.to_sym] = argv.shift
      elsif @vars[method_name]
        @vars[method_name]
      else
        super(method_name, argv)
      end
    end    
    
  end
end