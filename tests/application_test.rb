require File.expand_path('../helpers', __FILE__)

class ApplicationTest < MiniTest::Unit::TestCase

  def setup
    @app ||= ::VK::Application.new app_id: :test_id, app_secret: :test_secret, access_token: :test_token
    WebMock.reset!
  end

  def test_namespaces
    each_namespace do |namespace_name|
      object = @app.send namespace_name.to_sym

      assert_kind_of ::VK::Namespace, object
      assert_equal object.namespace, namespace_name
    end
  end

  def test_get_requests
    stubs_get!
    
    each_methods do |method_name|
      params = random_params.merge(verb: :get)
      assert_equal eval("@app.#{method_name}(params)"), params.merge(access_token: :test_token).stringify
    end
  end

  def test_post_request
    stubs_post!

    each_methods do |method_name|
      params = random_params
      assert_equal eval("@app.#{method_name}(params)"), params.merge(access_token: :test_token).stringify
    end
  end

end