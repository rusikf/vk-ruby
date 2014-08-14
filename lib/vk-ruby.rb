# encoding: UTF-8

# @title Ruby wrapper for vk.com API.
# @author Andrew Zinenko

require 'faraday'
require 'faraday_middleware'
require 'multi_json'
require 'openssl'
require 'forwardable'
require 'yaml'

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

require 'vk-ruby/errors/error'
require 'vk-ruby/errors/api_error'
require 'vk-ruby/errors/authorization_error'
require 'vk-ruby/errors/authentification_error'
require 'vk-ruby/errors/bad_response'

module VK
  class << self
    def config
      @config ||= VK::Config.new do |default|
        default.settings = 'notify,friends,offline'
        default.version = '5.20'
        default.host = 'https://api.vk.com'
        default.verb = :post
        default.timeout = 3
        default.open_timeout = 10

        default.ssl.tap do |ssl|
          ssl.verify = true
          ssl.verify_mode = ::OpenSSL::SSL::VERIFY_NONE
        end

        default.parallel_manager = Faraday::Adapter::EMHttp::Manager.new

        default.middlewares = proc do |faraday|
          faraday.request :multipart
          faraday.request :url_encoded

          faraday.response :vk_logger
          faraday.response :api_errors
          faraday.response :json, content_type: /\bjson$/
          faraday.response :http_errors

          faraday.adapter  Faraday.default_adapter
        end
      end
    end
    
    def configure
      yield(config) if block_given?
    end

    def site_auth(params)
      code = params.delete(:code)
      Application.new(params).tap { |app| app.site_auth(code: code) }
    end

    def server_auth(params)
      Application.new(params).tap { |app| app.server_auth(params) }
    end

    def authorization_url(params)
      Application.new.authorization_url(params)
    end
  end

end