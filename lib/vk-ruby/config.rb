# Application configuration wrapper
#
# @see http://rubydoc.info/gems/faraday/Faraday/Options

class VK::Config < Faraday::Options.new(:app_id, :app_secret, :version, :redirect_uri, :settings,
                                      :access_token, :verb, :host, :proxy, :ssl, :timeout,
                                      :open_timeout, :middlewares, :parallel_manager)
  
  # @!attribute [rw] app_id
  #   @return [String] application ID
  #
  # @!attribute [rw] app_secret
  #   @return [String] application Secret
  #
  # @!attribute [rw] version
  #   @return [String] API version
  #
  # @!attribute [rw] redirect_uri
  #   @return [String] application redirect URL
  #
  # @!attribute [rw] settings
  #   @return [String] application settings (see {https://vk.com/dev/permissions})
  #
  # @!attribute [rw] access_token
  #   @return [String] application access token
  #
  # @!attribute [rw] verb
  #   @return [String] HTTP verb
  #
  # @!attribute [rw] host
  #   @return [String] API host
  #
  # @!attribute [rw] proxy
  #   @return [Faraday::ProxyOptions] proxy settings (see {https://github.com/lostisland/faraday})
  #
  # @!attribute [rw] ssl
  #   @return [Faraday::SSLOptions] ssl settings (see {https://github.com/lostisland/faraday})
  #
  # @!attribute [rw] timeout
  #   @return [Fixnum] http request timeout
  #
  # @!attribute [rw] open_timeout
  #   @return [Fixnum] open http request timeout
  #
  # @!attribute [rw] middlewares
  #   @return [Proc] Faraday middlewares stack (see {https://github.com/lostisland/faraday})
  #
  # @!attribute [rw] parallel_manager 
  #   @return [Faraday::Adapter::EMHttp::Manager|Faraday::Adapter::EMSynchrony::ParallelManager] manager that this connection's adapter uses (see {https://github.com/lostisland/faraday})

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

  # Initialize a new VK::Config instance
  #
  # @param [Hash] params attributes values for the new config
  #
  # @yieldparam config [VK::Config] self

  def initialize(params={})
    params[:settings] ||= params.delete(:scope)
    params[:version] ||= params.delete(:v)
    params[:redirect_uri] ||= params.delete(:redirect_url)
    params[:middlewares] ||= params.delete(:stack)
    
    members.each { |member| self[member] = params[member.to_sym] }
    
    self.proxy = Faraday::ProxyOptions.from(params[:proxy]) if params[:proxy]
    self.ssl = Faraday::SSLOptions.from(params[:ssl]) if params[:ssl]

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