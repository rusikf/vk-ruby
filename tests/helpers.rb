require "vk-ruby"
require 'minitest/autorun'
require 'webmock'
require 'yaml'

include WebMock::API

if File.exists?("#{Dir.pwd}/config.yml")
  YAML.load_file("#{Dir.pwd}/config.yml").each do |name, value|
    self.class.const_set(name.upcase, value)
  end
end

def stubs_get!
  stub_request(:get, /https:\/\/api.vk.com\/method/).to_return(lambda { |request|
    {
      body: MultiJson.dump('response' => URI.parse(request.uri).query.to_params),
      headers: {"Content-Type" => 'application/json'}
    }
  })
end

def stubs_post!
  stub_request(:post, /https:\/\/api.vk.com\/method/).to_return(lambda { |request|
    {
      body: MultiJson.dump('response' => request.body.to_params),
      headers: {"Content-Type" => 'application/json'}
    }
  })
end

def stubs_http_error!
  stub_request(:post, /https:\/\/api.vk.com\/method/).to_return(lambda { |request|
    {
      body: MultiJson.dump('response' => request.body.to_params),
      headers: {"Content-Type" => 'application/json'},
      status: 500
    }
  })
end

def stubs_api_error!
  stub_request(:post, /https:\/\/api.vk.com\/method/).to_return(lambda { |request|
    {
      body: MultiJson.dump('error' => {'error_code' => 'code', 'error_msg' => 'message'}),
      headers: {"Content-Type" => 'application/json'}
    }
  })
end

def stubs_auth!
  stub_request(:get, /https:\/\/oauth.vk.com\/access_token/).to_return(lambda { |request|
    {
      body: MultiJson.dump(URI.parse(request.uri).query.to_params),
      headers: {"Content-Type" => 'application/json'}
    }
  })
end

def stubs_auth_error!
  stub_request(:get, /https:\/\/oauth.vk.com\/access_token/).to_return(lambda { |request|
    {
      body: MultiJson.dump('error' => 'message', 'error_description' => 'discription'),
      headers: {"Content-Type" => 'application/json'}
    }
  })
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

def api
  @api ||= YAML.load_file( File.expand_path( File.dirname(__FILE__) + "/api.yml" ))
end

def api_namespaces
  api.select { |e| e.is_a? Hash }
end

def api_methods
  api.map do |element|
    case element
    when String
      element
    when Hash
      element.map do |namespace, methods|
        methods.map {|method_name| [namespace, method_name].join('.') }
      end
    end
  end.flatten
end

def each_namespace
  api_namespaces.each do |namespace|
    namespace.keys.each { |namespace| yield namespace.to_sym if block_given? }
  end
end

def each_methods
  api_methods.each {|api_method| yield api_method.to_sym if block_given? }
end

def random_params(count = 3)
  (0...count).inject({}){|hash, num| hash[rand_str] = rand_str; hash}
end

def rand_str(length=7)
  (0...length).map{65.+(rand(25)).chr}.join.downcase
end