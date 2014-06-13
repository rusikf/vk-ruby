require 'helpers'

describe VK::Application, type: :application do
  let(:params) {{ 'uids' => '1' }}
  let(:host)   { /api.vk.com\/method/ }

  let(:post) {
    stub_request(:post, host).to_return({
      body: '{}',
      headers: {"Content-Type" => 'application/json'}
    })
  }

  let(:get) {
    stub_request(:get, host).to_return({
      body: '{}',
      headers: {"Content-Type" => 'application/json'}
    })
  }

  let(:request) { application.users.get(params) }

  before do
    post
    get
    request
  end

  describe :params do
    it { post.with(body: hash_including(params)).should have_been_requested }

    describe :version do
      let(:version) { '1' }
      let(:params) {{ version: version }}

      it { post.with(body: hash_including(v: version)).should have_been_requested }
    end

    describe :access_token do
      let(:params) {{ access_token: 'test' }}

      it { post.with(body: hash_including(params)).should have_been_requested }
    end

    describe :verb do
      context(:post) { it { post.should have_been_requested } }

      context(:get)  do 
        let(:params) {{ verb: :get }}

        it { get.should have_been_requested }
      end
    end

    describe :host do
      let(:host)   { /vkproxy.com\/method/ }
      let(:params) {{ host: 'http://vkproxy.com/' }}

      it { post.should have_been_requested }
    end

    describe :timeout do
      let(:request) {}
      let(:post)    { stub_request(:post, host).to_timeout }

      it { expect{ application.users.get(params) }.to raise_error(Faraday::TimeoutError) }
    end

    describe :ssl do
      context :on do
        let(:host) { /https:\/\/api.vk.com\/method/ }
        it { post.should have_been_requested }
      end

      context :off do
        let(:params) {{ ssl: false, host: 'http://api.vk.com/' }}
        let(:host)   { /http:\/\/api.vk.com\/method/ }

        it { post.should have_been_requested }
      end
    end
  end

end