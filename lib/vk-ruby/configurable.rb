# encoding: UTF-8

module VK::Configurable
	
  def attr_configurable attr_name, defaul = nil
  	define_method attr_name.to_sym do 
  		if instance_variable_get("@#{attr_name}")
		    instance_variable_get("@#{attr_name}")
		  else
		    VK.const_defined?(attr_name.upercase) ? VK.const_get(attr_name.upercase) : nil
		  end
  	end
  end

end