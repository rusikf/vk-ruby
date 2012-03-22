require File.expand_path('../helpers', __FILE__)

class ExceptionsTest < MiniTest::Unit::TestCase
  def setup
    @app = VK::Standalone.new :app_id => 2657696
  end

  def test_bad_requests
    response = lambda { |request| {:status => 500, :body => {:response => request.body.to_params}.to_json } }
    stub_request(:post, /https:\/\/api.vk.com\/method/).to_return response

    assert_raises(::VK::BadResponseException){ @app.getProfiles :uids => '123' }
  end

  def test_api_errors
    response = lambda { |request| {:body => {'error' => {'error_code' => 1, 'error_description' => 'discription'}}.to_json }}
    stub_request(:post, /https:\/\/api.vk.com\/method/).to_return response

    assert_raises(::VK::ApiException){ @app.getProfiles :uids => '123' }
  end
end