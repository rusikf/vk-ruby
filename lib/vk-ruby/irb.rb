require 'mechanize'
require 'irb'
require 'yaml'
require 'highline/import'
require 'docopt'

module VK
  class IRB
    extend Forwardable

    attr_reader :params, :config

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
      else
        case
        when params.eval?
          evaluate_code!
        when params.execute?
          execute_file!
        else
          start_session!
        end
      end  
    end

    private

    def context
      @context ||= VK::IRB::Context.new(config.context_config)
    end

    def list_user!
      config.users.each { |user_name, _| puts user_name }
    end

    def add_user!
      if config.user_exists? params.user_name
        if agree 'This user already exists, overwrite?'
          config.add_user(params.user_name, token)
        end
      else
        config.add_user(params.user_name, token)
      end

      config.save!
    end

    def remove_user!
      config.users.delete(params.user_name)
    end

    def update_user!
      if config.user_exists? params.user_name
        config.update_user(params.user_name, token)
      else
        if agree 'This user does not exists, add?'
          config.add_user(params.user_name, token)
        end
      end
    end

    def token
      params.token ? params.token : resolve_access_token
    end

    def evaluate_code!
      context.instance_eval(params.code)
    end

    def execute_file!
      File.open(params.file) { |file| context.instance_eval(file.read) }
    end

    def user
      config.users[params.user_name]
    end

    def start_session!
      ::IRB.setup(nil)
      
      ::IRB.conf[:SAVE_HISTORY] = config.save_history
      ::IRB.conf[:HISTORY_FILE] = config.history_file
      ::IRB.conf[:EVAL_HISTORY] = config.eval_history
      ::IRB.conf[:PROMPT_MODE] = :VK
      ::IRB.conf[:PROMPT][:VK] = {
        PROMPT_I: "#{ user ? user : 'unauthorized' } > ",
        PROMPT_S: "... ",
        PROMPT_C: "> ",
        PROMPT_N: "> ",
        RETURN: "#=> %s\n" 
      }

      workspace = ::IRB::WorkSpace.new(context)
      irb = ::IRB::Irb.new(workspace)

      ::IRB.conf[:MAIN_CONTEXT] = irb.context

      trap("SIGINT")   { irb.signal_handle }
      catch(:IRB_EXIT) { irb.eval_input }
    end

    private
    
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

      context.client_auth(login: login, password: password)
    end

  end
end

require 'vk-ruby/irb/config'
require 'vk-ruby/irb/context'
require 'vk-ruby/irb/params'