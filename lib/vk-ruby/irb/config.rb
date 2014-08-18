# CLI configuration wrapper

class VK::IRB::Config < Struct.new(:path, :app_name, :save_history, :eval_history, :users, :context_config)
  extend Forwardable

  VK::Config.members.each do |member|
    def_delegators :context_config, :"#{ member }", :"#{ member }="
  end

  def_delegator :context_config, :version,       :v
  def_delegator :context_config, :version=,      :v=
  def_delegator :context_config, :redirect_uri,  :redirect_url
  def_delegator :context_config, :redirect_uri=, :redirect_url=
  def_delegator :context_config, :settings,      :scope
  def_delegator :context_config, :settings=,     :scope=
  def_delegator :context_config, :middlewares,   :stack
  def_delegator :context_config, :middlewares=,  :stack=

  def initialize(path)
    self.path = path

    load_data.tap do |data|
      self.app_name = data[:app_name]
      self.save_history = data[:save_history]
      self.eval_history = data[:eval_history]
      self.users = data[:users] || {}
      self.context_config = VK::Config.new(data)
    end
  end

  def save!
    File.open(path, 'w') do |file| 
      data = VK::Utils.compact(to_h)
      data = VK::Utils.stringify(data)
      file.write data.to_yaml
    end
  end

  def add_user(user_name, token)
    users[user_name] = token
    save!
  end

  alias_method :update_user, :add_user

  def remove_user(user_name)
    users.delete(user_name)
    save!
  end

  def user_exists?(user_name)
    users.detect{ |name, _| user_name == name }
  end

  private

  def load_data
    if not File.exists?(path)
      if path == VK::IRB::Params::DEFAULT_CONFIG_FILE
        default_data
      else
        fail Errno::ENOENT.new("Config file `#{ path }` does not exits.")
      end
    else
      data = YAML.load File.open(path).read
      VK::Utils.symbolize data
    end
  end

  def default_data
    VK.config.to_h.merge({
      app_name: 'vk-irb',
      save_history: 100,
      eval_history: 10,
      users: {}
    })
  end

  def to_h
    self.context_config.to_h.merge({
      app_name: self.app_name,
      save_history: self.save_history,
      eval_history: self.eval_history
    }).tap { |h|
      h.delete(:access_token)
      h.delete(:parallel_manager)
      h.delete(:middlewares)
    }
  end

end