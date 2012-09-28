# encoding: UTF-8

module VK
  module Core
    extend ::Configurable
    extend Forwardable

    include VK::Namespace

    # @private
    NAMESPACES = [:users,
                  :likes,
                  :friends,
                  :groups,
                  :photos,
                  :wall,
                  :newsfeed,
                  :notifications,
                  :audio,
                  :video,
                  :docs,
                  :places,
                  :secure,
                  :storage,
                  :notes,
                  :pages,
                  :stats,
                  :subscriptions,
                  :widgets,
                  :leads,
                  :messages,
                  :status,
                  :polls,
                  :account,
                  :board,
                  :fave,
                  :auth,
                  :ads,
                  :orders]

    # Application ID that will be used to make each request.
    # @method app_id
    attr_configurable :app_id

    # Application secret that will be used to make authorize request.
    # @method app_secret

    attr_configurable :app_secret

    # Application settings(scope) that will be used to make authorize request.
    # Default `'notify,friends,offline'`
    # @method settings
    #
    # {http://vk.com/developers.php?oid=-1&p=%D0%9F%D1%80%D0%B0%D0%B2%D0%B0_%D0%B4%D0%BE%D1%81%D1%82%D1%83%D0%BF%D0%B0_%D0%BF%D1%80%D0%B8%D0%BB%D0%BE%D0%B6%D0%B5%D0%BD%D0%B8%D0%B9 Read more.}

    attr_configurable :settings, default: 'notify,friends,offline'

    # An access token needed by authorized requests.
    # @method access_token
    attr_configurable :access_token

    # Application logger.
    # @method logger
    attr_configurable :logger
    def_delegators :logger, :debug, :info, :warn, :error, :fatal, :level, :level=

    # Proxy params that will be used to make each request.
    # @method proxy
    attr_configurable :proxy

    attr_configurable :ssl, default: {
      verify: true,
      verify_mode: ::OpenSSL::SSL::VERIFY_NONE#,
      # ca_path:
      # ca_file
    }

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

    # A customized stack of Faraday middleware that will be used to make each request.
    attr_configurable :faraday_middleware

    # Faraday parallel request manager.
    # That will be used to make each request.
    # @method parallel_manager
    attr_configurable :parallel_manager, default: Faraday::Adapter::EMHttp::Manager.new

    # The duration of the token after authorization
    attr_accessor :expires_in

    # Is a your application instance authorized.
    def authorized?
      !self.access_token.nil?
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

    def vk_call(method_name, params = {})
      response = request("/method/#{method_name}", params || {})

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

        faraday.response :json,      content_type: /\bjson$/
        faraday.response :vk_logger, self.logger

        faraday.adapter  self.adapter
      end
    end

    # Files uploading.
    #
    # @param [Hash] params A list of files to upload (also includes the upload URL). See example for the hash format.
    #
    # @option params [String] :url URL for the request.
    #
    # @return [Hash] The server response.
    #
    # @raise [ArgumentError] raised when a `:url` parameter is omitted.
    #
    # @example
    #   your_application.upload(
    #     url:   'http://example.com/upload',
    #     file1: ['/path/to/file1.jpg', 'image/jpeg'],
    #     file2: ['/path/to/file2.png', 'image/png']
    #   )

    def upload(params = {})
      url = params.delete(:url)
      raise ArgumentError, 'You should pass :url parameter' unless url

      files = {}
      params.each do |param_name, (file_path, file_type)|
        files[param_name] = Faraday::UploadIO.new(file_path, file_type)
      end

      Faraday.new(&faraday_middleware).post(url, files)
    end

    # Authorization (getting the access token by code)
    # {http://vk.com/developers.php?oid=-1&p=%D0%90%D0%B2%D1%82%D0%BE%D1%80%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D1%8F_%D1%81%D0%B0%D0%B9%D1%82%D0%BE%D0%B2 Read more}
    #
    # @param [String] param - is param required from getting access token.
    # @param [Hash] params configurable options request. if you do not pass the option that will be used by the same name attribute.
    # @option params [Boolean] :save indicator that you want to save the returns parameters. Default `true`.
    # @option params [Symbol]  :type authorization type `:serverside` or `:secure`.
    # @option params [Symbol]  :code code param required for serverside authorization. Default `serverside`.
    #
    # @raise [VK::AuthorizeException] if vk.com return json with key error.

    def authorize(params = {})
      raise 'undefined application id'     unless self.app_id
      raise 'undefined application secret' unless self.app_secret

      params[:save].nil? ? (params[:save] = true) : (params[:save] = false)
      params[:type] ||= :serverside

      options = case params[:type]
      when :serverside
        {host: 'https://oauth.vk.com',
        client_id: self.app_id,
        client_secret: self.app_secret,
        code: params[:code],
        verb: :get}
      when :secure
        {host: 'https://oauth.vk.com',
        client_id: self.app_id,
        client_secret: self.app_secret,
        grant_type: :client_credentials,
        verb: :get}
      end

      response = request("/access_token", options)

      raise VK::AuthorizeException.new(response) if response.body['error']

      response.body.each{|k,v| instance_variable_set(:"@#{k}", v) } if params[:save]

      response.body
    end

    private

    # @private
    def request(path, options = {})
      host = options.delete(:host) || 'https://api.vk.com'
      verb = (options.delete(:verb) || self.verb).downcase.to_sym

      options[:access_token] ||= self.access_token if host == 'https://api.vk.com' && self.access_token

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
      params[:proxy] = options.delete(:proxy) || self.proxy
      params[:ssl] = options.delete(:ssl) || self.ssl

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