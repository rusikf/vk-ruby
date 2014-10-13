# Ruby wrapper for vk.com API
# @author Andrew Zinenko <andrew@izinenko.ru>

require 'faraday'
require 'faraday_middleware'
require 'multi_json'
require 'openssl'
require 'forwardable'
require 'yaml'
require 'mechanize'

require 'vk-ruby/version'
require 'vk-ruby/utils'

require 'vk-ruby/config'
require 'vk-ruby/namespaces'
require 'vk-ruby/methods'
require 'vk-ruby/middlewares/all'
require 'vk-ruby/core'
require 'vk-ruby/auth'
require 'vk-ruby/uploading'
require 'vk-ruby/application'
require 'vk-ruby/params'
require 'vk-ruby/auth_params'
require 'vk-ruby/fake_browser'

require 'vk-ruby/errors/error'
require 'vk-ruby/errors/api_error'
require 'vk-ruby/errors/authorization_error'
require 'vk-ruby/errors/authentification_error'
require 'vk-ruby/errors/bad_response'

module VK
  class << self

    # Global config
    def config
      @config ||= VK::Config.new
    end
    
    # Configure VK-RUBY
    #
    # @yieldparam config [VK::Config] global config

    def configure
      yield config if block_given?
    end

    # Get authorization URL helper
    #
    # @see VK::Auth#authorization_url

    def authorization_url(options={})
      Application.new.authorization_url(options={})
    end

    # Create a new application and performs site authorization
    #
    # @see VK::Auth#site_auth

    def site_auth(options={})
      Application.new(options).tap { |app| app.site_auth(code: options[:code]) }
    end

    # Create a new application and performs server authorization
    #
    # @see VK::Auth#server_auth

    def server_auth(options={})
      Application.new(options).tap { |app| app.server_auth }
    end

    # Create a new application and performs client authorization
    #
    # @see VK::Auth#client_auth

    def client_auth(options={})
      Application.new(options).tap do |app| 
        app.client_auth({
          login: options[:login],
          password: options[:password]
        })
      end
    end

  end
end
