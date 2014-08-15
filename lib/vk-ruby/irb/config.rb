# CLI configuration wrapper

class VK::IRB::Config < Struct.new(:path, :app_name, :save_history, :history_file, :eval_history, :users, :context_config)
  extend Forwardable

  SAVE_HISTORY = 100
  HISTORY_FILE = "#{ ENV['PWD'] }/.vk_history".freeze
  EVAL_HISTORY = 10

  def initialize(path)
    self.path = path
    load!
  end

  def_delegators :context_config, *VK::Config.members

  def load!
    if not File.exists?(path)
      fail(Errno::ENOENT.new("Config file `#{ path }` does not exits."))
    end

    file = File.open(path)
    data = YAML.load(file || {})
    
    symbolize(data).tap do |params|
      self.app_name = params.delete(:app_name)
      self.save_history = params.delete(:save_history) || SAVE_HISTORY
      self.history_file = params.delete(:history_file) || HISTORY_FILE
      self.eval_history = params.delete(:eval_history) || EVAL_HISTORY
      self.users = params.delete(:users) || {}
      self.context_config = VK::Config.new(params)
    end
  end

  def save!
    File.open(path, 'w') do |file|
      params = {
        app_name: self.app_name,
        save_history: self.save_history,
        history_file: self.history_file,
        eval_history: self.eval_history,
        users: self.users
      }

      params.merge! context_config.to_h
      params.delete :access_token
      params.delete :middlewares
      params.delete :parallel_manager

      file.write stringify(params).to_yaml
    end
  end

  def add_user(user_name, token)
    users[user_name] = token
    save!
  end

  alias update_user add_user

  def remove_user(user_name)
    users.delete(user_name)
    save!
  end

  def user_exists?(user_name)
    users.detect{ |name, _| user_name == name }
  end

  private

  def stringify(object)
    case object
    when Hash
      object.inject({}) { |acc, (k,v)| acc[k.to_s] = stringify(v); acc }
    when Array
      object.map(&:to_s)
    when Fixnum
      object
    else
      object.to_s
    end
  end

  def symbolize(object)
    case object
    when Hash
      object.inject({}) { |acc, (k,v)| acc[k.to_sym] = v; acc }
    when Array, Fixnum
      object
    else
      object.to_sym
    end
  end

end