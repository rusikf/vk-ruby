require 'helpers'

describe VK::Params do
  let(:config)  { 
    VK::Config.new({
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
      proxy: {
        uri: 'http://localhost:100500',
        user: 'config_user',
        password: 'config_password'
      },
      ssl: {
        verify: false,
        ca_file: 'new_ca_file',
        ca_path: 'new_ca_path',
        verify_mode: 5
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

    it { expect(params.ssl.verify).to eq(config[:ssl][:verify]) }
    it { expect(params.ssl.ca_file).to eq(config[:ssl][:ca_file]) }
    it { expect(params.ssl.ca_path).to eq(config[:ssl][:ca_path]) }
    it { expect(params.ssl.verify_mode).to eq(config[:ssl][:verify_mode]) }

    it { expect(params.proxy.uri).to eq(config[:proxy][:uri]) }
    it { expect(params.proxy.user).to eq(config[:proxy][:user]) }
    it { expect(params.proxy.password).to eq(config[:proxy][:password]) }

    it { expect(params.middlewares).to eq(config.middlewares) }
  end

  context 'with options' do
    let(:options) {{
      host: 'http://example.com',
      verb: :patch,
      timeout: 1,
      open_timeout: 2,
      ssl: { 
        verify: true,
        ca_file: '/path/to/ca.file',
        ca_path: '/path/to/ca.crt' 
      },
      proxy: {
        uri: 'http://options:100500',
        user: 'options_user',
        password: 'options_password'
      },
      middlewares: proc{}
    }}

    it { expect(params.host).to eq(options[:host]) }
    it { expect(params.verb).to eq(options[:verb]) }
    it { expect(params.timeout).to eq(options[:timeout]) }
    it { expect(params.open_timeout).to eq(options[:open_timeout]) }
    it { expect(params.middlewares).to eq(options[:middlewares]) }
    
    it { expect(params.ssl.verify).to eq(options[:ssl][:verify]) }
    it { expect(params.ssl.ca_file).to eq(options[:ssl][:ca_file]) }
    it { expect(params.ssl.ca_path).to eq(options[:ssl][:ca_path]) }
    it { expect(params.ssl.verify_mode).to eq(config[:ssl][:verify_mode]) }

    it { expect(params.proxy.uri).to eq(options[:proxy][:uri]) }
    it { expect(params.proxy.user).to eq(options[:proxy][:user]) }
    it { expect(params.proxy.password).to eq(options[:proxy][:password]) }
  end
end