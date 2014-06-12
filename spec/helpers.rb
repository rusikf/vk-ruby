require 'vk-ruby'
require 'pry'
require 'rspec'
require 'uri'
require 'yaml'
require 'webmock/rspec'

Dir['./spec/support/**/*.rb'].each { |f| require f }

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

class Hash
  def stringify
    inject({}) do |options, (key, value)|
      options[key.to_s] = value.to_s
      options
    end
  end
end