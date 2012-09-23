require File.expand_path('../helpers', __FILE__)

class StandaloneTest < MiniTest::Unit::TestCase
  def setup
    @base_api ||= YAML.load_file( File.expand_path( File.dirname(__FILE__) + "/../lib/vk-ruby/api/base.yml" ))
    @ext_api  ||= YAML.load_file( File.expand_path( File.dirname(__FILE__) + "/../lib/vk-ruby/api/ext.yml" ))
    @app = ::VK::Standalone.new app_id: :test_id, access_token: :test_token
    create_stubs!
  end

  def test_init_attributes
    assert_equal @app.app_id,       :test_id
    assert_equal @app.access_token, :test_token
    assert_nil @app.expires_in
    assert_nil @app.logger
  end

  def test_base_methods_exists
    cycle @app, @base_api do |obj, method_name, is_group|
      assert_respond_to obj, method_name.to_sym unless is_group
    end
  end

  def test_ext_methods_exists
    cycle @app, @ext_api do |obj, method_name, is_group|
      assert_respond_to obj, method_name.to_sym unless is_group
    end
  end

  def test_base_groups_exists
    cycle @app, @base_api do |obj, method_name, is_group|
      assert_instance_of ::Transformer::Group, obj if is_group
    end
  end

  def test_ext_groups_exists
    cycle @app, @ext_api do |obj, method_name, is_group|
      assert_instance_of ::Transformer::Group, obj if is_group
    end
  end

  def test_base_groups_methods_prefix
    cycle @app, @base_api do |obj, method_name, is_group|
      assert_equal obj.instance_variable_get("@methods_prefix"), method_name if is_group
    end
  end

  def test_ext_groups_methods_prefix
    cycle @app, @ext_api do |obj, method_name, is_group|
      assert_equal obj.instance_variable_get("@methods_prefix"), method_name if is_group
    end
  end

  def test_base_post_request_params
    cycle @app, @base_api do |obj, method_name, is_group|
      unless is_group
        params = random_params.merge!(access_token: :test_token)
        assert_equal obj.method(method_name.to_sym).call(params), params.stringify
      end
    end
  end

  def test_ext_post_request_params
    cycle @app, @ext_api do |obj, method_name, is_group|
      unless is_group
        params = random_params.merge!(access_token: :test_token)
        assert_equal obj.method(method_name.to_sym).call(params), params.stringify
      end
    end
  end

  def test_base_get_request_params
    cycle @app, @base_api do |obj, method_name, is_group|
      unless is_group
        params = random_params.merge!(access_token: :test_token, verb: :get)
        assert_equal obj.method(method_name.to_sym).call(params), params.stringify
      end
    end
  end

  def test_ext_get_request_params
    @app.verb = :get

    cycle @app, @ext_api do |obj, method_name, is_group|
      unless is_group
        params = random_params.merge!(access_token: :test_token)
        assert_equal obj.method(method_name.to_sym).call(params), params.stringify
      end
    end
  end

end