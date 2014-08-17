require 'helpers'

describe VK::AuthParams do
  let(:config)  { VK::Config.new({
      app_id:  'new_app_id',
      app_secret: 'new_app_secret',
      version: 'new_version',
      redirect_uri: 'new_redirect_uri',
      settings: 'new_settings',
      verb: 'new_verb',
      host: 'new_host', 
      timeout: 'new_timeout',
      open_timeout: 'new_open_timeout',
      middlewares: proc{},
      parallel_manager: Object.new,
      proxy: { user: 'new_user', password: 'new_password'},
      ssl: {
        verify: false,
        ca_file: 'new_ca_file',
        ca_path: 'new_ca_path'
      }
    })
  }


  # check

  let(:params) { VK::AuthParams.new(config, options) }

  context 'with empty options' do
    let(:options) { {} }

    it { expect(params.code).to be_nil }
    it { expect(params.app_id).to eq(config.app_id) }
    it { expect(params.app_secret).to eq(config.app_secret) }
    it { expect(params.version).to eq(config.version) }
    it { expect(params.redirect_url).to eq(config.redirect_url) }
    it { expect(params.settings).to eq(config.settings) }
    it { expect(params.display).to eq(:page) }
    it { expect(params.login).to be_nil }
    it { expect(params.password).to be_nil }
  end

  context 'with options' do
    let(:options) {{
      code: :code,
      app_id: :app_id,
      app_secret: :app_secret,
      version: '6.0',
      redirect_url: 'http://example.com',
      settings: 'foo,bar',
      display: :display_type,
      login: :user_login,
      password: :user_password
    }}

    it { expect(params.code).to eq(options[:code]) }
    it { expect(params.app_id).to eq(options[:app_id]) }
    it { expect(params.app_secret).to eq(options[:app_secret]) }
    it { expect(params.version).to eq(options[:version]) }
    it { expect(params.redirect_url).to eq(options[:redirect_url]) }
    it { expect(params.settings).to eq(options[:settings]) }
    it { expect(params.display).to eq(options[:display]) }
    it { expect(params.type).to be_nil }
    it { expect(params.login).to eq(options[:login]) }
    it { expect(params.password).to eq(options[:password]) }

  end
end