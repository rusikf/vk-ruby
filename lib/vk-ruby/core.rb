# encoding: UTF-8

module VK
  module Core
    extend Configurable
    extend Forwardable

    attr_accessor :faraday_middleware

    attr_configurable :app_id, :access_token, :logger

    attr_configurable :ca_path, :ca_file, :verify_mode

    attr_configurable :proxy

    attr_configurable :use_ssl, :verify, default: true

    attr_configurable :verb,            default: :post
    attr_configurable :timeout,         default: 2
    attr_configurable :open_timeout,    default: 3
    attr_configurable :adapter,         default: Faraday.default_adapter

    def_delegators :logger, :debug, :info, :warn, :error, :fatal, :level, :level=

    [:base, :ext, :secure].each do |name|
      class_eval(<<-EVAL, __FILE__, __LINE__ + 1)
        def #{name}_api
          @@#{name}_api ||= YAML.load_file( File.expand_path( File.dirname(__FILE__) + "/api/#{name}.yml" ))
        end
      EVAL
    end

    def vk_call(method_name, params)
      response = request("/method/#{method_name}", ((params.is_a?(Array) ? params.shift : params) || {}))

      raise VK::ApiException.new(method_name, response.body) if response.body['error']

      response.body['response']
    end

    def in_parallel(manager = nil, &block)
      Faraday.new(parallel_manager: manager) do
        yield if block_given?
      end
    end

    def faraday_middleware
      @faraday_middleware || proc do |faraday|
        faraday.request :multipart
        faraday.request :url_encoded

        faraday.response :json, content_type: /\bjson$/

        # faraday.response :normalize_utf
        # faraday.response :validate_utf
        # faraday.response :vk_logger, self.logger

        faraday.adapter  self.adapter
      end
    end

    private

    def request(path, options = {})
      host = options.delete(:host) || 'https://api.vk.com'
      verb = (options.delete(:verb) || self.verb).downcase.to_sym

      options[:access_token] ||= self.access_token if host == 'https://api.vk.com'

      params, body = http_params(verb, options)

      response = Faraday.new(host, params, &faraday_middleware).send(verb, path, body)

      raise VK::BadResponseException.new(response, verb, path, options) if response.status.to_i != 200

      response
    end

    def http_params(verb, options)
      params = {}

      params[:timeout] = options.delete(:timeout) || self.timeout
      params[:open_timeout] = options.delete(:open_timeout) || self.open_timeout
      params[:proxy]   = options.delete(:proxy)   || self.proxy
      params[:use_ssl] = options.delete(:use_ssl) || self.use_ssl
      params[:verify]  = options.delete(:verify)  || self.verify

      if params[:use_ssl]
        _ca_path = params.delete(:ca_path) || self.ca_path
        _ca_file = params.delete(:ca_file) || self.ca_file
        _verify_mode = params.delete(:verify_mode) || self.verify_mode

        if _ca_path || _ca_file || _verify_mode
          params[:ssl] = {}
          params[:ssl][:ca_path] = _ca_path if _ca_path
          params[:ssl][:ca_file] = _ca_file if _ca_file
          params[:ssl][:verify_mode] = _verify_mode if _verify_mode
        end
      end

      if verb == :get
        params[:params] = options
        return params, {}
      else
        params[:params] = {}
        return params, options
      end
    end

    def encode_params(params)
      params.map do |key, value|
        value = MultiJson.dump(value) unless value.is_a?(String) || value.is_a?(Symbol)
        [CGI.escape(key.to_s), CGI.escape(value.to_s)].join('=')
      end.join("&")
    end

  end
end