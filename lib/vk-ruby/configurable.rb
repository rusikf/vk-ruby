# encoding: UTF-8

module VK
  module Configurable

    def attr_configurable(*arr)
      params = arr.pop if arr.last.is_a?(Hash)

      arr.each do |a_name|

        attr_writer a_name.to_sym

        define_method(a_name) do

          if !instance_variable_get(:"@#{a_name}") && !instance_variable_get(:"@set_default_value_#{a_name}") && params && params[:default]
            instance_variable_set(:"@#{a_name}", params[:default])
            instance_variable_set(:"@set_default_value_#{a_name}", true)
          end

          if variable = instance_variable_get(:"@#{a_name}")
            variable
          elsif constant = self.class.try_const_get(a_name.upcase)
            constant
          end

        end

      end
    end

    def try_const_get(const_name)
      self.name.split('::').inject([]) do |result, name|
        result << eval([result.last, name].join('::'))
        result
      end.inject(nil) do |result, clas|
        begin
          value = clas.const_get(const_name)
          break value
        rescue NameError
          nil
        end
      end
    end

  end
end