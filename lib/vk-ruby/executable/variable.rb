module VK::Executable
  class Variable

    def initialize(addr, chain)
      @addr = addr
    end

    def map(name)
#      self.
    end

    # def =(other_var)
      
    # end

    # def +=(other_var)
      
    # end

    # def +(other_var)
      
    # end

    private

    def set_name(name)
      @name = name
      @addr[name] = self
    end

    def method_missing(method_name)
      set_name method_name.to_sym
    end    

  end
end