require 'helpers'

describe VK::IRB::Config do
  let(:path)             { 'config file path' }
  let(:config)           { VK::IRB::Config.new(path) }

  let(:app_id)           { 'app_id' }
  let(:app_name)         { 'app_name' }
  let(:app_secret)       { 'app_secret' }
  let(:eval_history)     { 'eval history file path' }
  let(:history_file)     { 'save history file path' }
  let(:host)             { 'host' }
  let(:middlewares)      { 'faraday middlewares' }
  let(:open_timeout)     { 'open_timeout' }
  let(:parallel_manager) { 'parallel_manager' }
  let(:proxy_password)   { 'password' }
  let(:proxy_user)       { 'user' }
  let(:redirect_uri)     { 'redirect_uri' }
  let(:save_history)     { 100 }
  let(:settings)         { 'settings' }
  let(:ssl_ca_file)      { 'ssl_ca_file' }
  let(:ssl_ca_path)      { 'ssl_ca_path' }
  let(:ssl_verify)       { 'ssl_verify' }
  let(:timeout)          { 'timeout' }
  let(:users)            {{ 'admin' => 'token1' }}
  let(:verb)             { 'verb' }
  let(:version)          { 'version' }

  let(:data) {{
    app_id: app_id,
    app_name: app_name,
    app_secret: app_secret,
    eval_history: eval_history,
    history_file: history_file,
    host: host, 
    middlewares: middlewares,
    open_timeout: open_timeout,
    parallel_manager: parallel_manager,
    redirect_uri: redirect_uri,
    save_history: save_history,
    settings: settings,
    timeout: timeout,
    users: users,
    verb: verb,
    version: version,
    proxy: { 
      user: proxy_user,
      password: proxy_password
    },
    ssl: {
      verify: ssl_verify,
      ca_file: ssl_ca_file,
      ca_path: ssl_ca_path
    }
  }}

  before { VK::IRB::Config.any_instance.stub(:load_data).and_return(data) }

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
      it { config.user_exists?(users.keys.first).should be_true }
      it { config.user_exists?('admin1').should be_false }
    end
  end

end