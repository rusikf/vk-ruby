require File.expand_path('../helpers', __FILE__)

class AuthTest < MiniTest::Unit::TestCase

  def setup
    @app ||= ::VK::Application.new app_id: :test_id, app_secret: :test_secret, access_token: :test_token
    WebMock.reset!
    stubs_auth!
  end

  def test_serverside_authorization
    params = {client_id: :test_id ,client_secret: :test_secret, type: :serverside, code: :test_code, redirect_uri: '--'}

    assert_equal @app.authorize(params) ,{"client_id"=>"test_id", "client_secret"=>"test_secret", "code"=>"test_code", "redirect_uri" => '--'}
  end

  def test_secure_authorization
    params = {client_id: :test_id ,client_secret: :test_secret, type: :secure}
    
    assert_equal @app.authorize(params), {"client_id"=>"test_id", "client_secret"=>"test_secret", "grant_type"=>"client_credentials"}
  end

end