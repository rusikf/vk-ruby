require File.expand_path('../helpers', __FILE__)

class ApplicationTest < MiniTest::Unit::TestCase
  def setup
    @app = ::VK::Application.new app_id: :test_id, app_secret: :test_secret, access_token: :test_token
    create_stubs!
  end

  def test_namespaces
    each_namespace @app, api do |object, namespace|
      assert_kind_of ::VK::Namespace, object
      assert_equal object.namespace, namespace
    end
  end

  def test_post_request_params
    each_methods @app, api do |obj, method_name|
      unless method_name == :send
        params = random_params.merge!(access_token: :test_token)
        # # POST request
        assert_equal obj.send(method_name, params), params.stringify
        # # GET request
        params.merge(verb: :get)
        assert_equal obj.send(method_name, params), params.stringify
      end
    end
  end

  def test_authorization
    params = {client_id: :test_id ,client_secret: :test_secret}
    assert_equal @app.authorize(params.merge type: :secure) , {"client_id"=>"test_id", "client_secret"=>"test_secret", "grant_type"=>"client_credentials"}
    assert_equal @app.authorize(params.merge type: :serverside, code: :test_code, redirect_uri: '--') ,{"client_id"=>"test_id", "client_secret"=>"test_secret", "code"=>"test_code", "redirect_uri" => '--'}
  end

  def test_bad_requests
    assert_raises(::VK::BadResponseException) do
      @app.getProfiles http_error: :error
    end
  end

  def test_api_errors
    assert_raises(::VK::ApiException) do
      @app.getProfiles error: :error
    end
  end

end