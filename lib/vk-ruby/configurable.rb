# encoding: UTF-8

module VK::Configurable
	
  def attr_configurable(*arr)
  	params = arr.pop if arr.last.is_a?(Hash)

  	arr.each do |a_name|
	  	define_method(a_name) do
	  		instance_variable_set(:"@#{a_name}", params[:default]) if !instance_variable_get(:"@#{a_name}") && params && params[:default]

	  		if variable = instance_variable_get(:"@#{a_name}")
	  			variable 
	  		elsif self.class.const_defined?(a_name.upcase, true)
	  			self.class.const_get(a_name.upcase, true)
	  		end
	  	end

  		define_method("#{a_name}=") do |value|
				instance_variable_set(:"@#{a_name}", value)
  		end

	  end

  end

  def extended(cls)
  	cls.include self
  end

end