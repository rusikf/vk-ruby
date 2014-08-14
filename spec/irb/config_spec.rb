require 'helpers'

describe VK::IRB::Config do
  let(:path)             { 'config file path' }
  let(:config)           { VK::IRB::Config.new(path) }
  let(:app_name)         { 'app_name' }
  let(:save_history)     { 100 }
  let(:history_file)     { 'save history file path' }
  let(:eval_history)     { 'eval history file path' }
  let(:app_id)           { 'app_id' }
  let(:app_secret)       { 'app_secret' }
  let(:version)          { 'version' }
  let(:redirect_uri)     { 'redirect_uri' }
  let(:settings)         { 'settings' }
  let(:verb)             { 'verb' }
  let(:host)             { 'host' }
  let(:timeout)          { 'timeout' }
  let(:open_timeout)     { 'open_timeout' }
  let(:parallel_manager) { 'parallel_manager' }
  let(:middlewares)      { 'faraday middlewares' }
  let(:proxy_user)       { 'user' }
  let(:proxy_password)   { 'password' }
  let(:ssl_verify)       { 'ssl_verify' }
  let(:ssl_ca_file)      { 'ssl_ca_file' }
  let(:ssl_ca_path)      { 'ssl_ca_path' }
  let(:users)            {{ }}

  let(:data) {{
    'app_name' => app_name,
    'save_history' => save_history,
    'history_file' => history_file,
    'eval_history' => eval_history,
    'users' => users,
    'app_id' => app_id,
    'app_secret' => app_secret,
    'version' => version,
    'redirect_uri' => redirect_uri,
    'settings' => settings,
    'verb' => verb,
    'host' => host, 
    'timeout' => timeout,
    'open_timeout' => open_timeout,
    'middlewares' => middlewares,
    'parallel_manager' => parallel_manager,
    'proxy' => { 
      'user' => proxy_user,
      'password' => proxy_password
    },
    'ssl' => {
      'verify' => ssl_verify,
      'ca_file' => ssl_ca_file,
      'ca_path' => ssl_ca_path
    }
  }}

  before do 
    File.stub(:exists?).with(path).and_return(true)
    File.stub(:exists?).with("/Users/andi/.pry_history").and_return(false)
    File.stub(:open).with(path).and_return(data)
    YAML.stub(:load).with(data).and_return(data)
  end

  it { config.app_name.should eq(app_name) }
  it { config.save_history.should eq(save_history) }
  it { config.history_file.should eq(history_file) }
  it { config.eval_history.should eq(eval_history) }
  it { config.users.should eq(users) }
  it { config.app_id.should eq(app_id) }
  it { config.app_secret.should eq(app_secret) }
  it { config.version.should eq(version) }
  it { config.redirect_uri.should eq(redirect_uri) }
  it { config.settings.should eq(settings) }
  it { config.verb.should eq(verb) }
  it { config.host.should eq(host) }
  it { config.timeout.should eq(timeout) }
  it { config.open_timeout.should eq(open_timeout) }
  
  it { config.middlewares.should eq(middlewares) }
  it { config.parallel_manager.should eq(parallel_manager) }
  
  it { config.proxy.user.should eq(proxy_user) }
  it { config.proxy.password.should eq(proxy_password) }
  
  it { config.ssl.verify.should eq(ssl_verify) }
  it { config.ssl.ca_file.should eq(ssl_ca_file) }
  it { config.ssl.ca_path.should eq(ssl_ca_path) }

  describe 'users' do
    let(:users) {{ 'admin' => 'token1' }}

    before { config.stub(:save!) }

    describe 'add_user' do
      it { expect{ config.add_user('new_admin', 'token2') }.to change{ config.users } }
      it { expect{ config.add_user('new_admin', 'token2') }.to change{ config.users['new_admin'] } }
      it { expect{ config.add_user('new_admin', 'token2') }.to change{ config.users.values } }
      it { expect{ config.add_user('new_admin', 'token2') }.to change{ config.users.keys } }
    end

    describe 'update_user' do
      it { expect{ config.update_user('admin', 'token3') }.to change{ config.users } }
      it { expect{ config.update_user('admin', 'token3') }.to change{ config.users['admin'] } }
      it { expect{ config.update_user('admin', 'token3') }.to change{ config.users.values } }
      it { expect{ config.update_user('admin', 'token3') }.to_not change{ config.users.keys } }
    end

    describe 'remove_user' do
      it { expect{ config.remove_user('admin') }.to change{ config.users } }
      it { expect{ config.remove_user('admin') }.to change{ config.users['admin'] } }
      it { expect{ config.remove_user('admin') }.to change{ config.users.values } }
      it { expect{ config.remove_user('admin') }.to change{ config.users.keys } }
    end

    describe 'user_exists?' do
      it { config.user_exists?('admin').should be_true }
      it { config.user_exists?('admin1').should be_false }
    end
  end

end