require File.expand_path('../helpers', __FILE__)

class ServersideTest < MiniTest::Unit::TestCase
  def setup
    @base_api ||= YAML.load_file( File.expand_path( File.dirname(__FILE__) + "/../lib/vk-ruby/api/base.yml" ))
    @app = ::VK::Serverside.new app_id: :test_id, app_secret: :test_secret, access_token: :test_token
    create_stubs!
  end

  def test_init_attributes
    assert_equal @app.app_id,       :test_id
    assert_equal @app.app_secret,   :test_secret
    assert_equal @app.access_token, :test_token
    assert_nil @app.expires_in
    assert_nil @app.logger
  end

  def test_methods_exists
    cycle @app, @base_api do |obj, method_name, is_group|
      assert_respond_to obj, method_name.to_sym unless is_group
    end
  end

  def test_groups_exists
    cycle @app, @base_api do |obj, method_name, is_group|
      assert_instance_of ::Transformer::Group, obj if is_group
    end
  end

  def test_groups_methods_prefix
    cycle @app, @base_api do |obj, method_name, is_group|
      assert_equal obj.instance_variable_get("@methods_prefix"), method_name if is_group
    end
  end

  def test_post_request_params
    cycle @app, @base_api do |obj, method_name, is_group|
      unless is_group
        params = random_params.merge!(access_token: :test_token)
        assert_equal obj.method(method_name.to_sym).call(params), params.stringify
      end
    end
  end

  def test_get_request_params
    cycle @app, @base_api do |obj, method_name, is_group|
      unless is_group
        params = random_params.merge!(access_token: :test_token, verb: :get)
        assert_equal obj.method(method_name.to_sym).call(params), params.stringify
      end
    end
  end

  def test_authorization
    params = {code: :test_code, client_id: :test_id ,client_secret: :test_secret}
    assert_equal @app.authorize(params[:code]) , params.stringify
  end

end