require 'net/https'
require 'transformer'
require 'yaml'
require 'yajl'

module VK
end

VK::JSON = begin
  require 'yajl'
  ::Yajl
rescue LoadError
  require 'json'
  ::JSON
end

%w(core_ext connection core secure serverside standalone vk_exception).each{|lib| require "vk-ruby/#{lib}"}