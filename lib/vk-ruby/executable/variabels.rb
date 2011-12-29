module VK::Executable
  class Variables

    def initialize
      @vars = {}
    end

    def to_hash
      @vars
    end

    def to_json
      @vars.to_json
    end

    private 

    def method_missing(method_name, *argv)
      if attribute_name = method_name[/(\w+)?=/,1]
        @vars[attribute_name.to_sym] = argv.shift
      elsif @vars[method_name]
        @vars[method_name]
      else
        puts @vars.keys.include?(method_name) ? "ok" : 'error'
        super(method_name, argv)
      end
    end    
    
  end
end