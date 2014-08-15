# Authorization and authentification methods

module VK::Auth

  # @!attribute [rw] expires_in
  #   @return [Fixnum] lifetime of the token
  attr_accessor :expires_in

  # @!attribute [r] access_token
  #   @return [String] current access token
  attr_accessor :access_token

  # Default client/standalone application redirect URL
  DEFAULT_CLIENT_REDIRECT_URL = 'https://oauth.vk.com/blank.html'.freeze

  # Checking authorizing application
  #
  # @return [Boolean]
  def authorized?
    !!access_token
  end

  # Get current access token
  #
  # @return [String] access token (config.access_token)

  def access_token
    @access_token || config.access_token
  end

  # Get authorization URL
  #
  # @param [Hash] params required for serverside authorization
  # @option params [Symbol] :type application type, :client or :standalone or :site or :serverside
  # @option params [String] :app_id (config.app_id) application ID
  # @option params [String] :settings (config.settings) application settings flag separate by comma (see {https://vk.com/dev/permissions})
  # @option params [String] :version (config.version) API version
  # @option params [String] :redirect_uri (config.redirect_url or DEFAULT_CLIENT_REDIRECT_URL) redirect URL
  # @option params [Symbol] :display (:page) window type of authorization, :page or :popup or :mobile
  #
  # @return [String] authorization URL
  #
  # @example Get standalone/client authorization URL (see {https://vk.com/dev/auth_mobile})
  #   application.authorization_url({
  #     type: :client,
  #     app_id: 123,
  #     settings: 'friends,audio',
  #     version: '5.20',
  #     redirect_uri: 'https://example.com/',
  #     display: :mobile
  #   })
  #
  #   #=> "https://oauth.vk.com/authorize?client_id=123&scope=friends,audio&redirect_uri=https://example.com/&display=mobile&response_type=token&v=5.20"
  #
  # @example Get serverside authorization URL (see {https://vk.com/dev/auth_sites})
  #   application.authorization_url({
  #     type: :site,
  #     app_id: 123,
  #     settings: 'friends,audio',
  #     version: '5.20',
  #     redirect_uri: 'https://example.com/'
  #   })
  #
  #   #=> "https://oauth.vk.com/authorize?client_id=123&scope=friends,audio&redirect_uri=https://example.com/&response_type=token&v=5.20"

  def authorization_url(params)
    app_id = params[:app_id] || config.app_id
    settings = params[:scope] || params[:settings] || config.settings
    version = params[:v] || params[:version] || config.version
    redirect_url = params[:redirect_uri] || params[:redirect_url] || config.redirect_url
    display = params[:display] || :page

    redirect_url ||= DEFAULT_CLIENT_REDIRECT_URL if [:client, :standalone].include?(params[:type])

    fail(ArgumentError, 'You should pass :app_id parameter')       unless app_id
    fail(ArgumentError, 'You should pass :redirect_url parameter') unless redirect_url
    fail(ArgumentError, 'You should pass :settings parameter')     unless settings
    fail(ArgumentError, 'You should pass :version parameter')      unless version

    settings = settings.join(',') if settings.is_a?(Array)
    
    case params[:type]
    when :client, :standalone
      "https://oauth.vk.com/authorize?" << URI.encode_www_form({
        client_id: app_id,
        scope: settings,
        redirect_uri: redirect_url,
        display: display,
        response_type: :token,
        v: version
      })
    when :site, :serverside
      "https://oauth.vk.com/authorize?" << URI.encode_www_form({
        client_id: app_id,
        scope: settings,
        redirect_uri: redirect_url,
        response_type: :token,
        v: version
      })
    end
  end

  # Site authorization (see {http://vk.com/dev/auth_sites})
  #
  # @param [Hash] params required for serverside authorization
  # @option params [String] :app_id (config.app_id) application ID
  # @option params [String] :app_secret (config.app_secret) application secret
  # @option params [String] :version (config.version) API version
  # @option params [String] :redirect_url (config.redirect_url) redirect URL
  # @option params [String] :code authorization code
  #
  # @return [Object] server response
  #
  # @raise [VK::AuthorizationError] if server response has error keys
  # @raise [VK::APIError] with API error
  #
  # @example Receive access token (see {https://vk.com/dev/auth_sites})
  #

  def site_auth(params={})
    app_id = params[:app_id] || config.app_id
    app_secret = params[:app_secret] || config.app_secret
    version = params[:version] || config.version
    redirect_url = params[:redirect_url] || config.redirect_url

    fail(ArgumentError, 'You should pass :code parameter')         unless params[:code]
    fail(ArgumentError, 'You should pass :app_id parameter')       unless app_id
    fail(ArgumentError, 'You should pass :app_secret parameter')   unless app_secret
    fail(ArgumentError, 'You should pass :version parameter')      unless version
    fail(ArgumentError, 'You should pass :redirect_url parameter') unless redirect_url

    options = {
      host: 'https://oauth.vk.com',
      client_id: app_id,
      client_secret: app_secret,
      code: params[:code],
      redirect_uri: redirect_url,
      verb: :get,
      v: version
    }

    response = request(options) { |req| req.url "/access_token" }

    self.expires_in = response.body['expires_in']
    self.access_token = response.body['access_token']

    response.body
  end

  # Application secure server authorization (see {http://vk.com/dev/auth_server})
  #
  # @param [Hash] params required for serverside authorization
  # @option params [String] :app_id (config.app_id) application ID
  # @option params [String] :app_secret (config.app_secret) application secret
  #
  # @return [Object] server response
  #
  # @raise [VK::AuthorizationError] if server response has error keys
  # @raise [VK::APIError] with API error

  def server_auth(params={})
    app_id = params[:app_id] || config.app_id
    app_secret = params[:app_secret] || config.app_secret

    fail(ArgumentError, 'You should pass :app_id parameter')     unless app_id
    fail(ArgumentError, 'You should pass :app_secret parameter') unless app_secret

    options = {
      host: 'https://oauth.vk.com',
      client_id: app_id,
      client_secret: app_secret,
      grant_type: :client_credentials,
      verb: :get
    }

    response = request(options) { |req| req.url "/access_token" }

    self.expires_in = 0
    self.access_token = response.body['access_token']

    response.body
  end

  # Client/standalone authentication and authorization (see {https://vk.com/dev/auth_mobile})
  #
  # @param [Hash] params required for serverside authorization
  # @option params [String] :app_id (config.app_id) application ID
  # @option params [String] :app_secret (config.app_secret) application secret
  # @option params [String] :settings (config.settings) application settings flag separate by comma (see {https://vk.com/dev/permissions})
  # @option params [String] :login user login
  # @option params [String] :password user password
  #
  # @return [Object] access token
  #
  # @raise [VK::AuthentificationError] with invalid login or password
  # @raise [VK::APIError] with API error

  def client_auth(params={})
    app_id = params[:app_id] || config.app_id
    settings = params[:settings] || params[:scope] || config.settings

    fail(ArgumentError, 'You should pass :app_id parameter')   unless app_id
    fail(ArgumentError, 'You should pass :settings parameter') unless settings
    fail(ArgumentError, 'You should pass :login parameter')    unless params[:login]
    fail(ArgumentError, 'You should pass :password parameter') unless params[:password]

    agent = Mechanize.new
    agent.user_agent_alias = 'Mac Safari'

    begin
      agent.get authorization_url(app_id: app_id, settings: settings, type: :client) << '&revoke=1'

      agent.page.form_with(action: /login.vk.com/){ |form|
        form.email = params[:login]
        form.pass  = params[:password]
      }.submit
    rescue Exception => ex
      if ex.is_a?(VK::APIError)
        raise
      else
        raise VK::AuthentificationError.new({
          error: 'Authentification error',
          description: 'invalid loging or password'
        })
      end
    end

    if agent.cookies.detect{|cookie| cookie.name == 'remixsid'}
      sleep 1

      url = agent.page
               .body
               .gsub("\n",'')
               .gsub("  ",'')
               .match(/.*function allow\(\)\s?\{.*}location.href\s?=\s?[\'\"\s](.+)[\'\"].+\}/)
               .to_a
               .last

      agent.get(url)
    else
      raise VK::AuthorizationError.new({
        error: 'Authorization error',
        error_description: 'invalid loging or password'
      })
    end

    sleep 1

    response = agent.page
                    .uri
                    .fragment
                    .split('&')
                    .map{ |s| s.split '=' }
                    .inject({}){ |a, (k,v)| a[k] = v; a }

    self.expires_in = response['expires_in']
    self.access_token = response['access_token']

    response
  end

end
