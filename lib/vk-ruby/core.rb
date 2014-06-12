# encoding: UTF-8

module VK::Core

  def config
    @config ||= VK.config.dup
  end

  # Calling API method.
  #
  # {http://vk.com/developers.php?oid=-1&p=%D0%92%D1%8B%D0%BF%D0%BE%D0%BB%D0%BD%D0%B5%D0%BD%D0%B8%D0%B5_%D0%B7%D0%B0%D0%BF%D1%80%D0%BE%D1%81%D0%BE%D0%B2_%D0%BA_API Read more}

  def vk_call(method_name, params = {})
    params[:access_token] ||= access_token if access_token
    params[:v] ||= config.version

    response = request(params) { |req| req.url "/method/#{ method_name }" }
    response.body['response']
  end

  # Parallel API methods calling.
  #
  # @params [Faraday::Adapter::EMHttp::Manager|Faraday::Adapter::EMSynchrony::ParallelManager] manager that this connection's adapter uses.

  def in_parallel(manager = nil)
    manager ||= config.parallel_manager

    Faraday.new(parallel_manager: manager).in_parallel do
      yield if block_given?
    end
  end

  private

  # @private
  def request(params)
    host = params.delete(:host) || config.host
    verb = params.delete(:verb) || config.verb
    timeout = params.delete(:timeout) || config.timeout
    open_timeout = params.delete(:open_timeout) || config.open_timeout

    ssl = config.ssl.merge params.delete(:ssl) || {}

    proxy = if proxy_params = params.delete(:proxy)
      proxy = config.proxy ? config.proxy.merge(proxy) : Faraday::ProxyOptions.from(proxy)
    end
    
    middlewares = params.delete(:middlewares) || config.middlewares
    
    Faraday.new(url: host, ssl: ssl, proxy: proxy, &middlewares).send(verb) do |req|
      req.options.timeout = timeout
      req.options.open_timeout = open_timeout

      if Faraday::Env::MethodsWithBodies.include? verb
        req.body = params
      else
        req.params = params
      end
      
      yield(req) if block_given?
    end
  end
end
