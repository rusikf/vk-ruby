# encoding: UTF-8

module VK::Configurable
	
  def attr_configurable *arr
  	params = arr.pop if arr.last.is_a?(Hash)

  	arr.each do |attr_name|
	  	define_method attr_name.to_sym do 
	  		(var = instance_variable_get("@#{attr_name}")) ? var : (const = VK.const_defined?(attr_name.upcase) ? const : nil)
	  	end
	  end
  end

end