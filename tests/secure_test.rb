require File.expand_path('../helpers', __FILE__)

class SecureServerTest < MiniTest::Unit::TestCase
  def setup
    @app = ::VK::Secure.new app_id: :test_id, app_secret: :test_secret
    @secure_api = YAML.load_file( File.expand_path( File.dirname(__FILE__) + "/../lib/vk-ruby/api/secure.yml" ))
    create_stubs!
  end

  def test_init_attributes
    assert_equal @app.app_id,     :test_id
    assert_equal @app.app_secret, :test_secret
    assert_nil @app.logger
  end

  def test_methods_exists
    cycle @app, @secure_api do |obj, method_name, is_group|
      assert_respond_to obj, method_name.to_sym unless is_group
    end
  end

  def test_authorization
    params = {client_id: :test_id, client_secret: :test_secret, grant_type: :client_credentials }
    assert_equal @app.authorize , params.stringify
  end

  def test_raises_initialize
    assert_raises(RuntimeError) do
      ::VK::Serverside.new {}
    end

    assert_raises(RuntimeError) do
      ::VK::Serverside.new app_id: :test_id
    end
  end

end