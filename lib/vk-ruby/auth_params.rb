class VK::AuthParams < Struct.new(:config, :options)

  # Default client/standalone application redirect URL
  DEFAULT_CLIENT_REDIRECT_URL = 'https://oauth.vk.com/blank.html'.freeze

  def code
    options[:code]
  end

  def app_id
    options[:app_id] || config.app_id
  end

  def app_secret
    options[:app_secret] || config.app_secret
  end

  def version
    options[:v] || options[:version] || config.version
  end

  def redirect_url
    if [:client, :standalone].include?(type)
      DEFAULT_CLIENT_REDIRECT_URL
    else
      options[:redirect_url] || options[:redirect_url] || config.redirect_url
    end
  end

  def settings
    options[:settings] || options[:scope] || config.settings
  end

  def display
    options[:display] || :page
  end

  def type
    options[:type]
  end

  def login
    options[:login]
  end

  def password
    options[:password]
  end
  
end