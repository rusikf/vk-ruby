require 'vk-ruby'
require 'pry'
require 'rspec'
require 'uri'
require 'yaml'
require 'webmock/rspec'

Dir['./spec/support/**/*.rb'].each { |f| require f }

VK.configure do |default|
  default.timeout = 1
  default.open_timeout = 1

  default.middlewares = proc do |faraday|
    faraday.request :multipart
    faraday.request :url_encoded

    faraday.response :api_errors
    faraday.response :json, content_type: /\bjson$/
    faraday.response :http_errors

    faraday.adapter  Faraday.default_adapter
  end
end

RSpec.configure do |config|
  config.order = 'random'
  
  config.include ApplicationGroup, type: :application
  config.include MiddlewareGroup,  type: :middleware
  config.include ErrorGroup,       type: :exception
  config.include IntegrationGroup, type: :integration

  unless ENV['INTEGRATION'] || File.exists?('./support/credentials.yml')
    config.filter_run_excluding type: :integration
  end
end

class String
  def to_params
    self.split('&').inject({}) do |hash, element|
      k, v = element.split('=')
      hash[k] = v
      hash
    end
  end
end