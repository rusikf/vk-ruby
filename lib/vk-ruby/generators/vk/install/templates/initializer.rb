module VK
  # APP_ID = 222
  # APP_SECRET = "foobar"
  # ACCESS_TOKEN = "your acceess token"

  LOGGER = Rails.logger

  ## Proxy settings.
  # PROXY = {
  #   host: 'http://example.com',
  #   user: 'foo',
  #   password: 'bar'
  # }

  ## SSL settings.
  ## Read more https://github.com/technoweenie/faraday/wiki/Setting-up-SSL-certificates .
  # USE_SSL = true
  # VERIFY = false
  # VERIFY_MODE = ::OpenSSL::SSL::VERIFY_NONE
  # CA_PATH = "/usr/lib/ssl/certs"
  # CA_FILE = "/usr/lib/ssl/certs/ca-certificates.crt"

  ## Faraday HTTP settings.
  # VERB = :post
  # TIMEOUT = 5
  # OPEN_TIMEOUT = 2
  # ADAPTER = :em_http
  # PARALLEL_MANAGER = Faraday::Adapter::EMHttp::Manager.new
end