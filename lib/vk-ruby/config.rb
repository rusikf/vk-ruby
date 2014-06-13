module VK
  class Config < Faraday::Options.new(:app_id, :app_secret, :version, :redirect_uri, :settings,
                                      :access_token, :verb, :host, :proxy, :ssl, :timeout,
                                      :open_timeout, :middlewares, :parallel_manager)
    alias v version
    alias v= version=

    alias redirect_url redirect_uri
    alias redirect_url= redirect_uri=

    alias scope settings
    alias scope= settings=

    alias stack middlewares
    alias stack= middlewares=

    options ssl: Faraday::SSLOptions, proxy: Faraday::ProxyOptions

    memoized(:ssl) { self.class.options_for(:ssl).new }

    def initialize(params={})
      params[:settings] ||= params.delete(:scope)
      params[:version] ||= params.delete(:v)
      params[:redirect_uri] ||= params.delete(:redirect_url)
      super(params)
      yield self if block_given?
    end

    def merge(params)
      dup.tap do |config|
        config.ssl.merge! params.delete(:ssl) || {}

        if proxy_options = params.delete(:proxy)
          config.proxy = config.proxy ? config.proxy.merge!(proxy_options) : Faraday::ProxyOptions.from(proxy_options)
        end

        params.each { |k,v| send("#{k}=", v) }
      end  
    end

  end
end