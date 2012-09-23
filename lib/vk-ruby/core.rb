# encoding: UTF-8

module VK
  module Core
    extend Configurable
    extend Forwardable

    # A customized stack of Faraday middleware that will be used to make each request.
    attr_accessor :faraday_middleware

    # Application ID that will be used to make each request.
    # @method app_id
    attr_configurable :app_id

    # An access token needed by authorized requests.
    # @method access_token
    attr_configurable :access_token

    # Application logger.
    # @method logger
    attr_configurable :logger

    # Proxy params that will be used to make each request.
    # @method proxy
    attr_configurable :proxy

    # Param indicating indicating that you need to use ssl.
    # That will be used to make each request.
    # @method use_ssl
    attr_configurable :use_ssl, default: true

    # Param indicating that you need to verify peer..
    # That will be used to make each request.
    # @method verify
    attr_configurable :verify, default: false

    # Param specifying the ssl verification strategy that you need to use ssl.
    # That will be used to make each request.
    # @method verify_mode
    attr_configurable :verify_mode, default: ::OpenSSL::SSL::VERIFY_NONE

    # An ssl ca_path option that will be used to make each request.
    # @method ca_path
    attr_configurable :ca_path

    # A ssl ca_file option that will be used to make each request.
    # @method ca_file
    attr_configurable :ca_file

    # Verb the HTTP method to used to make each request.
    # @method verb
    attr_configurable :verb, default: :post

    # Number of seconds to wait for the connection to open.
    # Any number may be used, including Floats for fractional seconds.
    # If the HTTP object cannot open a connection in this many seconds,
    # it raises a TimeoutError exception.
    # That will be used to make each request.
    # @method timeout
    attr_configurable :timeout, default: 5

    # Number of seconds to wait for one block to be read (via one read(2) call).
    # Any number may be used, including Floats for fractional seconds.
    # If the HTTP object cannot read data in this many seconds,
    # it raises a TimeoutError exception.
    # That will be used to make each request.
    # @method open_timeout
    attr_configurable :open_timeout, default: 3

    # Faraday HTTP adapter.
    # That will be used to make each request.
    # @method adapter
    attr_configurable :adapter, default: Faraday.default_adapter


    # Faraday parallel request manager.
    # That will be used to make each request.
    # @method parallel_manager
    attr_configurable :parallel_manager, default: Faraday::Adapter::EMHttp::Manager.new

    # Base api methods.
    # @method base_api
    #
    # @return [Hash] list of base api methods.

    # Extended api methods (available only standalone application).
    # @method ext_api
    #
    # @return [Hash] list of extended api methods.

    # Secure api methods (available only secure server application).
    # @method secure_api
    #
    # @return [Hash] list of secure api methods.

    [:base, :ext, :secure].each do |name|
      class_eval(<<-EVAL, __FILE__, __LINE__ + 1)
        def #{name}_api
          @@#{name}_api ||= YAML.load_file( File.expand_path( File.dirname(__FILE__) + "/api/#{name}.yml" ))
        end
      EVAL
    end

    # Is a your application instance authorized.
    def authorized?
      !@access_token.nil?
    end

    # Calling API method.
    # {http://vk.com/developers.php?oid=-1&p=%D0%92%D1%8B%D0%BF%D0%BE%D0%BB%D0%BD%D0%B5%D0%BD%D0%B8%D0%B5_%D0%B7%D0%B0%D0%BF%D1%80%D0%BE%D1%81%D0%BE%D0%B2_%D0%BA_API Read more}
    #
    # @param [String] method_name A full name of the method.
    # @param [Hash] params configurable options request. if you do not pass the option that will be used by the same name attribute.
    # @option params [String] :host host request.
    # @option params [String] :verb http verb request. Only `:get` or `:post`.
    # @option params [String] :access_token your access token.
    # @option params [String] :open_timeout  open_timeout request.
    # @option params [String] :timeout timeout request.
    # @option params [Hash] :proxy proxy params request.
    # @option params [Boolean] :use_ssl indicating that you need to use ssl.
    # @option params [Boolean] :verify indicating that you need to verify peer.
    # @option params [String] :verify_mode specifying the ssl verification strategy that you need to use ssl.
    # @option params [String] :ca_path ssl ca_path.
    # @option params [String] :ca_file ssl ca_file.
    # @option params [String] :other_options the other options are considered as api method parameters.
    #
    # @return [Hash|Array]
    #
    # @raise an appropriate connection error if unable to make the request to vk.com.
    # @raise if vk.com return json with key error.

    def vk_call(method_name, params)
      response = request("/method/#{method_name}", ((params.is_a?(Array) ? params.shift : params) || {}))

      raise VK::ApiException.new(method_name, response.body) if response.body['error']

      response.body['response']
    end

    # Parallel API methods calling.
    #
    # @params [Faraday::Adapter::EMHttp::Manager|Faraday::Adapter::EMSynchrony::ParallelManager] manager that this connection's adapter uses.

    def in_parallel(manager = nil)
      Faraday.new(parallel_manager:( manager || parallel_manager)).in_parallel do
        yield if block_given?
      end
    end

    # VK_RUBY default middleware stack.
    # We encode requests in a vk.com - compatible multipart request,
    # and use whichever adapter has been configured for this application.

    def faraday_middleware
      @faraday_middleware || proc do |faraday|
        faraday.request  :multipart
        faraday.request  :url_encoded

        faraday.response :json, content_type: /\bjson$/

        # faraday.response :normalize_utf
        # faraday.response :validate_utf
        # faraday.response :vk_logger, self.logger

        faraday.adapter  self.adapter
      end
    end

    private

    # @private
    def request(path, options = {})
      host = options.delete(:host) || 'https://api.vk.com'
      verb = (options.delete(:verb) || self.verb).downcase.to_sym

      options[:access_token] ||= self.access_token if host == 'https://api.vk.com'

      params, body = http_params(verb, options)

      response = Faraday.new(host, params, &faraday_middleware).send(verb, path, body)

      raise VK::BadResponseException.new(response, verb, path, options) if response.status.to_i != 200

      response
    end

    # @private
    def http_params(verb, options)
      params = {}

      params[:open_timeout] = options.delete(:open_timeout) || self.open_timeout
      params[:timeout] = options.delete(:timeout) || self.timeout
      params[:proxy]   = options.delete(:proxy)   || self.proxy
      params[:use_ssl] = options.delete(:use_ssl) || self.use_ssl
      params[:verify]  = options.delete(:verify)  || self.verify

      if params[:use_ssl]
        _ca_path = params.delete(:ca_path) || self.ca_path
        _ca_file = params.delete(:ca_file) || self.ca_file
        _verify_mode = params.delete(:verify_mode) || self.verify_mode

        if _ca_path || _ca_file || _verify_mode
          params[:ssl] = {}
          params[:ssl][:ca_path] = _ca_path         if _ca_path
          params[:ssl][:ca_file] = _ca_file         if _ca_file
          params[:ssl][:verify_mode] = _verify_mode if _verify_mode
        end
      else
        params[:ssl] = false
      end

      if verb == :get
        params[:params] = options
        return params, {}
      else
        params[:params] = {}
        return params, options
      end
    end

  end
end