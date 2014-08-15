# API calling methods

module VK::Core

  # Get current application config 
  #
  # @return [VK::Config] application config
  def config
    @config ||= VK.config.dup
  end

  # Calling API method
  # 
  # @param method_name [String] API method name (see {https://vk.com/dev/methods})
  # @param params [Hash] API method params (see {https://vk.com/dev/methods})
  #
  # @return [String] server response
  #
  # @example get information about Pavel Durov 
  #   VK::Application.new.vk_call 'users.get', user_ids: 1 #=> [{"id"=>1, "first_name"=>"Павел", "last_name"=>"Дуров"}]

  def vk_call(method_name, params = {})
    params[:access_token] ||= access_token if access_token
    params[:v] ||= params.delete(:version) || config.version

    response = request(params) { |req| req.url "/method/#{ method_name }" }
    response.body['response']
  end

  # Parallel API methods calling
  #
  # @param [Faraday::Adapter::EMHttp::Manager|Faraday::Adapter::EMSynchrony::ParallelManager] manager that this connection's adapter uses
  #
  # @example parallel getting information about users
  #   uids = { 1 => {}, 2 => {}, 3 => {}}
  #
  #   VK::Application.new.in_parallel do
  #     uids.each do |uid,_|
  #       app.users.get(user_ids: uid).each do |user|
  #         uids[user["id"]] = user
  #       end
  #     end
  #   end
  #
  #   puts uids #=> {
  #     1 => {"id"=>1, "first_name"=>"Павел", "last_name"=>"Дуров"}, 
  #     2 => {"id"=>2, "first_name"=>"Александра", "last_name"=>"Владимирова", "hidden"=>1}, 
  #     3 => {"id"=>3, "first_name"=>"DELETED", "last_name"=>"", "deactivated"=>"deleted"}
  #   }
  #
  # @return nothing :-)

  def in_parallel(manager = nil)
    manager ||= config.parallel_manager

    Faraday.new(parallel_manager: manager).in_parallel do
      yield if block_given?
    end
  end

  private

  def request(params)
    host = params.delete(:host) || config.host
    verb = params.delete(:verb) || config.verb
    timeout = params.delete(:timeout) || config.timeout
    open_timeout = params.delete(:open_timeout) || config.open_timeout

    ssl = params.delete(:ssl)
    ssl = config.ssl.merge(ssl || {}) if ssl != false

    proxy = params.delete(:proxy)
    proxy = proxy and config.proxy ? config.proxy.merge(proxy) : Faraday::ProxyOptions.from(proxy)
    
    middlewares = params.delete(:middlewares) || config.middlewares
    host = host.gsub('https', 'http') unless ssl

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
