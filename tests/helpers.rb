require "vk-ruby"
require 'minitest/autorun'
require 'webmock'

include WebMock::API

def create_stubs!
  stub_request(:get, /https:\/\/api.vk.com\/method/).to_return(lambda { |request| 
    {
      body: {'response' => URI.parse(request.uri).query.to_params}.to_json,
      headers: {"Content-Type" => 'application/json'}
    }  
  })

  stub_request(:post, /https:\/\/api.vk.com\/method/).to_return(lambda { |request|
    body = request.body.to_params
    status = body.has_key?('http_error') ? 500 : 200

    response = body.has_key?('error') ? {'error' => {}} : {'response' => body}

    {
      body: response.to_json,
      headers: {"Content-Type" => 'application/json'},
      status: status
    } 
  })

  stub_request(:get, /https:\/\/oauth.vk.com\/access_token/).to_return(lambda { |request| 
    {
      body: {'response' => URI.parse(request.uri).query.to_params}.to_json,
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

  def to_json
    MultiJson.encode self
  end

  def stringify!
   each do |key, value|
     delete(key)
     store(key.to_s, value.to_s)
   end
  end
end

def cycle(object, elements, &block)
  case elements
    when String
      block.call(object, elements, false)
    when Array
      elements.each {|element| cycle object, element, &block}
    else Hash
      elements.each do |group_name, methods| 
        group = object.send(group_name.to_sym)
        block.call(group, group_name, true)
        cycle group, methods, &block
      end
    end
end


def random_params(count = 3)
  (0...count).inject({}){|hash, num| hash[rand_str] = rand_str; hash}
end

def rand_str(length=7)
  (0...length).map{65.+(rand(25)).chr}.join.downcase
end