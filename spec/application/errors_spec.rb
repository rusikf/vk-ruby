require 'helpers'

describe VK::Application, type: :application do
  let(:options) {{ 
    app_id: :test_id,
    app_secret: :test_secret,
    access_token: :test_token,
    redirect_url: :test_redirect_url
  }}

  before(:all) { stubs_auth! }

  context 'bad request' do
    before { stubs_http_error! }

    it { expect{ subject.users.get }.to raise_error(VK::BadResponse) }
  end

  context 'api error' do
    before { stubs_api_error! }

    it { expect{ subject.users.get }.to raise_error(VK::APIError) }
  end

  context 'auth error' do
    let(:params) {{
      client_id: :test_id,
      client_secret: :test_secret,
      type: :secure
    }}

    let(:code) { :code }

    before { stubs_auth_error! }

    it { expect{ subject.site_auth(code: code) }.to raise_error(VK::AuthorizationError) }
  end

end
