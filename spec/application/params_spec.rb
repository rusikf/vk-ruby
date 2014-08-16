require 'helpers'

describe VK::Params do
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

  let(:params) { VK::Params.new(config, options) }

  context 'with empty options' do
    let(:options) { {} }

    it { expect(params.host).to eq(config.host) }
    it { expect(params.verb).to eq(config.verb) }
    it { expect(params.timeout).to eq(config.timeout) }
    it { expect(params.open_timeout).to eq(config.open_timeout) }
    it { expect(params.ssl).to eq(config.ssl) }
    it { expect(params.proxy).to eq(config.proxy) }
    it { expect(params.middlewares).to eq(config.middlewares) }
  end

  context 'with options' do
    let(:options) {{
      host: 'http://example.com',
      verb: :patch,
      timeout: 1,
      open_timeout: 2,
      ssl: { verify: true, ca_file: '/path/to/ca.file', ca_path: '/path/to/ca.crt' },
      proxy: "user:password@example.com",
      middlewares: proc{}
    }}

    it { expect(params.host).to eq(options[:host]) }
    it { expect(params.verb).to eq(options[:verb]) }
    it { expect(params.timeout).to eq(options[:timeout]) }
    it { expect(params.open_timeout).to eq(options[:open_timeout]) }
    it { expect(params.ssl).to eq(config.ssl.merge(options[:ssl])) }
    it { expect(params.proxy).to eq(config.proxy.merge(Faraday::ProxyOptions.from(options[:proxy]))) }
    it { expect(params.middlewares).to eq(options[:middlewares]) }
  end
end