require File.expand_path('../helpers', __FILE__)

class VkApiTest < MiniTest::Unit::TestCase

  def setup
    @base_api ||= YAML.load_file( File.expand_path( File.dirname(__FILE__) + "/../lib/vk-ruby/api/base.yml" ))
    @ext_api ||= YAML.load_file( File.expand_path( File.dirname(__FILE__) + "/../lib/vk-ruby/api/ext.yml" ))
    @executable = VK::Executable::Api.new
  end  

  def test_base_api
    perebor @executable, @base_api do |obj, method_name, is_group|
      unless is_group
        api_reg = /\AAPI\.\w*\.?#{method_name}\z/
        assert_match api_reg, obj.method(method_name.to_sym).call
      end
    end
  end

  def test_ext_api
    perebor @executable, @ext_api do |obj, method_name, is_group|
      unless is_group
        api_reg = /\AAPI\.\w*\.?#{method_name}\z/
        assert_match api_reg, obj.method(method_name.to_sym).call
      end
    end
  end

  def test_base_api_and_params
    perebor @executable, @base_api do |obj, method_name, is_group|
      unless is_group
        params = random_params
        api_method = [api_method,'(', params.to_json ,')'].join
        api_reg = /\AAPI\.\w*\.?#{method_name}\(.+\)\z/
        assert_match api_reg, obj.method(method_name.to_sym).call(params)
      end
    end
  end

  def test_ext_api_and_params
    perebor @executable, @ext_api do |obj, method_name, is_group|
      unless is_group
        params = random_params
        api_method = [api_method,'(', params.to_json ,')'].join
        api_reg = /\AAPI\.\w*\.?#{method_name}\(.+\)\z/
        assert_match api_reg, obj.method(method_name.to_sym).call(params)
      end
    end
  end
  
end