module VK::ConfigureAttributes
    
  def configure_attr_accessor(*names)
    configure_attr_reader(*names)
    attr_writer(*names)
  end

  def configure_attr_reader(*names)
    names.each do |name|
      define_method name do 
        instance_variable_get("@#{ name }") || 
        instance_variable_set("@#{ name }", VK.send(name)) # set default value
      end
    end
  end

end