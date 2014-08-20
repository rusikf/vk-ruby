require 'mechanize'
require 'irb'
require 'yaml'
require 'highline/import'
require 'docopt'

# IRB mode implementation
class VK::IRB
  extend Forwardable

  attr_reader :params, :config

  DEFAULT_RC_FILE = "#{ ENV['HOME'] }/.vkrc.rb".freeze

  def_delegators :@highline, :ask, :say, :agree

  def initialize(docopt)
    @params = VK::IRB::Params.new(docopt)
    @config = VK::IRB::Config.new(@params.config_file)
    @highline = HighLine.new
  end

  def run!
    case
    when params.list?
      list_user!
    when params.add?
      add_user!
    when params.remove?
      remove_user!
    when params.update?
      update_user!
    when params.eval?
      evaluate_code!
    when params.execute?
      execute_file!
    else
      start_session!
    end  
  end

  private

  def context
    @context ||= VK::IRB::Context.new(config).tap do |ctx|
      ctx.access_token = config.users[params.user_name.to_sym] if user
      rc_files.each { |file| ctx.instance_eval File.open(file).read }
    end
  end

  def workspace
    @workspace ||= ::IRB::WorkSpace.new(context)
  end

  def irb
    @irb ||= ::IRB::Irb.new(workspace)
  end

  def rc_files
    @rc_files ||= [
      DEFAULT_RC_FILE,
      "#{ ENV['PWD'] }/.vkrc.rb"
    ].compact.select {|f| File.exists?(f) }
  end

  def list_user!
    config.users.each { |user_name, _| say user_name.to_s }
  end

  def add_user!
    if config.user_exists? params.user_name
      if agree 'This user already exists, overwrite?'
        config.update_user(params.user_name, token)
        say 'User successfully overwritted.'
      end
    else
      config.add_user(params.user_name, token)
      say 'User successfully added.'
    end

    config.save!
  end

  def remove_user!
    config.remove_user(params.user_name)
    say 'User successfully removed.'
  end

  def update_user!
    if config.user_exists? params.user_name
      config.update_user(params.user_name, token)
      say 'User successfully updated.'
    else
      if agree 'This user does not exists, add?'
        config.add_user(params.user_name, token)
        say 'User successfully added.'
      end
    end
  end

  def token
    params.token ? params.token : resolve_access_token
  end

  def evaluate_code!
    say context.instance_eval(params.evaluated_code).to_s
  end

  def execute_file!
    File.open(params.executed_file) { |file| context.instance_eval(file.read) }
  end

  def user
    config.users[params.user_name.to_sym] ? params.user_name : nil
  end

  def start_session!
    say "User '#{ params.user_name }' does not exists." unless user
    setup
    ::IRB.conf[:MAIN_CONTEXT] = irb.context
    
    begin
      trap("SIGINT")   { irb.signal_handle }
      catch(:IRB_EXIT) { irb.eval_input }
    ensure
      config.save!
    end
  end

  def setup
    ::IRB.setup(nil)
    ::IRB.conf[:PROMPT_MODE] = :VK
    ::IRB.conf[:PROMPT][:VK] = {
      PROMPT_I: "#{ config.app_name } : #{ user ? user : 'unauthorized' } > ",
      PROMPT_S: "... ",
      PROMPT_C: "> ",
      PROMPT_N: "> ",
      RETURN: "#=> %s\n" 
    }
  end
  
  def resolve_access_token
    login = ask "login: " do |question|
      question.echo = false
      question.readline = true
      question.overwrite = true
    end

    password = ask "password: " do |question|
      question.echo = false
      question.readline = true
      question.overwrite = true
    end

    context.client_auth(login: login, password: password)['access_token']
  end

end

require 'vk-ruby/irb/config'
require 'vk-ruby/irb/context'
require 'vk-ruby/irb/params'