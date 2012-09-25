require "vk-ruby"
require 'minitest/autorun'
require 'webmock'
require 'yaml'

include WebMock::API

if File.exists?("#{Dir.pwd}/config.yml")
  YAML.load_file("#{Dir.pwd}/config.yml").each do |name, value|
    self.class.const_set name.upcase, value
  end
end

def create_stubs!
  stub_request(:get, /https:\/\/api.vk.com\/method/).to_return(lambda { |request|
    {
      body: MultiJson.dump('response' => URI.parse(request.uri).query.to_params),
      headers: {"Content-Type" => 'application/json'}
    }
  })

  stub_request(:post, /https:\/\/api.vk.com\/method/).to_return(lambda { |request|

    body = request.body.to_params
    status = body.has_key?('http_error') ? 500 : 200

    response = body.has_key?('error') ? {'error' => {}} : {'response' => body}

    {
      body: MultiJson.dump(response),
      headers: {"Content-Type" => 'application/json'},
      status: status
    }
  })

  stub_request(:get, /https:\/\/oauth.vk.com\/access_token/).to_return(lambda { |request|
    {
      body: MultiJson.dump(URI.parse(request.uri).query.to_params),
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

def each_namespace(object, element, &block)
  brute object, element do |obj, method_name, is_namespace|
    block.call(obj, method_name) if is_namespace
  end
end

def each_methods(object, element, &block)
  brute object, element do |obj, method_name, is_namespace|
    block.call(obj, method_name) unless is_namespace
  end
end

def brute(object, elements, &block)
  case elements
    when String
      block.call(object, elements.to_sym, false)
    when Array
      elements.each {|element| brute object, element, &block}
    else Hash
      elements.each do |namespace_name, methods|
        namespace = object.send(namespace_name.to_sym)

        block.call(namespace, namespace_name.to_sym, true)

        brute namespace, methods, &block
      end
    end
end

def random_params(count = 3)
  (0...count).inject({}){|hash, num| hash[rand_str] = rand_str; hash}
end

def rand_str(length=7)
  (0...length).map{65.+(rand(25)).chr}.join.downcase
end
