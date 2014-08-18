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
    if block_given?
      manager ||= config.parallel_manager
      Faraday.new(parallel_manager: manager).in_parallel { yield }
    end
  end

  private

  def request(options)
    params = VK::Params.new(config, options)
    connection = Faraday.new(url: params.host, ssl: params.ssl, proxy: params.proxy, &params.middlewares)

    connection.send(params.verb) do |req|
      req.options.timeout = params.timeout
      req.options.open_timeout = params.open_timeout

      if methods_with_bodies? params.verb.to_sym
        req.body = params.query
      else
        req.params = params.query
      end
      
      yield(req) if block_given?
    end
  end

  def methods_with_bodies?(verb)
    Faraday::Env::MethodsWithBodies.include?(verb)
  end
end
