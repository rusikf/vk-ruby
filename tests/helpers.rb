require "vk-ruby"
require 'minitest/autorun'
require 'webmock/minitest'

class String 
  def to_params
    result = {}
    self.split('&').map{|str| result[str.split('=')[0]]=str.split('=')[1] }
    result
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
    Oj.dump self
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