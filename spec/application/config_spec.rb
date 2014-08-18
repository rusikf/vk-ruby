require 'helpers'

describe VK::Config do
  it { VK::Application.new.config.should eq(VK.config) }

  describe 'merge config' do
    let(:options) {{
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
        uri: 'http://host:8080',
        user: 'new_user', 
        password: 'new_password'
      },
      ssl: {
        verify: false,
        verify_mode: false,
        ca_file: 'new_ca_file',
        ca_path: 'new_ca_path'
      }
    }}

    let(:application) { VK::Application.new(options) }
    
    subject { application.config }

    its(:app_id)           { should eq(options[:app_id]) }
    its(:app_secret)       { should eq(options[:app_secret]) }
    its(:version)          { should eq(options[:version]) }
    its(:redirect_uri)     { should eq(options[:redirect_uri]) }
    its(:settings)         { should eq(options[:settings]) }
    its(:verb)             { should eq(options[:verb]) }
    its(:host)             { should eq(options[:host]) }
    its(:timeout)          { should eq(options[:timeout]) }
    its(:open_timeout)     { should eq(options[:open_timeout]) }
    its(:middlewares)      { should eq(options[:middlewares]) }
    its(:parallel_manager) { should eq(options[:parallel_manager]) }

    it { expect(application.config.ssl.verify).to eq(options[:ssl][:verify]) }
    it { expect(application.config.ssl.ca_file).to eq(options[:ssl][:ca_file]) }
    it { expect(application.config.ssl.ca_path).to eq(options[:ssl][:ca_path]) }
    it { expect(application.config.ssl.verify_mode).to eq(options[:ssl][:verify_mode]) }

    it { expect(application.config.proxy.uri).to eq(options[:proxy][:uri]) }
    it { expect(application.config.proxy.user).to eq(options[:proxy][:user]) }
    it { expect(application.config.proxy.password).to eq(options[:proxy][:password]) }
  end

end