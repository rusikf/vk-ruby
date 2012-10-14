require File.expand_path('../helpers', __FILE__)

class ExceptionTest < MiniTest::Unit::TestCase

  def setup
    @app ||= ::VK::Application.new app_id: :test_id, app_secret: :test_secret, access_token: :test_token
    WebMock.reset!
  end

  def test_bad_requests
    stubs_http_error!

    assert_raises(::VK::BadResponseException) { @app.users.get }
  end

  def test_api_errors
    stubs_api_error!
    
    assert_raises(::VK::ApiException) { @app.users.get }
  end

  def test_auth_errors
    stubs_auth_error!
    params = {client_id: :test_id ,client_secret: :test_secret, type: :secure}

    assert_raises(::VK::AuthorizeException) { @app.authorize(params) }
  end

end