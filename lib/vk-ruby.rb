require 'net/https'
require 'transformer'
require 'yaml'

module VK; end

begin
  require 'yajl'
  require 'yajl/json_gem'
rescue LoadError
  require 'json'
end

%w(ext connection executable/variable executable/chain executable/method core secure serverside standalone vk_exception).each{|lib| require "vk-ruby/#{lib}"}