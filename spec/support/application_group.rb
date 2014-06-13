module ApplicationGroup

  def self.included(base)
    base.let(:options)     {{ }}
    base.let(:application) { VK::Application.new(options) }

    base.before { WebMock.reset! }
    base.subject { application }
  end

  def stubs_http_error!
    stub_request(:post, /https:\/\/api.vk.com\/method/).to_return(lambda { |request|
      {
        body: MultiJson.dump('response' => request.body.to_params.reject{|k| k == :v}),
        headers: {"Content-Type" => 'application/json'},
        status: 500
      }
    })
  end

  def stubs_api_error!
    stub_request(:post, /https:\/\/api.vk.com\/method/).to_return(lambda { |request|
      {
        body: MultiJson.dump('error' => {'error_code' => 'code', 'error_msg' => 'message'}),
        headers: {"Content-Type" => 'application/json'}
      }
    })
  end

  def stubs_auth!
    stub_request(:get, /https:\/\/oauth.vk.com\/access_token/).to_return(lambda { |request|
      {
        body: MultiJson.dump(URI.parse(request.uri).query.to_params.reject{|k| k == :v}),
        headers: {"Content-Type" => 'application/json'}
      }
    })
  end

  def stubs_auth_error!
    stub_request(:get, /https:\/\/oauth.vk.com\/access_token/).to_return(lambda { |request|
      {
        body: MultiJson.dump('error' => 'message', 'error_description' => 'discription'),
        headers: {"Content-Type" => 'application/json'}
      }
    })
  end

end