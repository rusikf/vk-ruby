require File.expand_path('../helpers', __FILE__)

class ExceptionsTest < MiniTest::Unit::TestCase
  def setup
    @app = VK::Standalone.new app_id: 2657696
  end

  def test_bad_requests
    assert_raises(::VK::BadResponseException) do 
      @app.getProfiles http_error: {}
    end
  end

  def test_api_errors
    assert_raises(::VK::ApiException) do
      @app.getProfiles error: {}
    end
  end
end