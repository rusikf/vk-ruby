# encoding: UTF-8

require 'net/https'
require 'cgi'
require 'transformer'
require 'yaml'

module VK
end

begin
  require 'yajl'
  require 'yajl/json_gem'
rescue LoadError
  require 'json'
end

%w(connection core secure serverside standalone vk_exception).each{|lib| require "vk-ruby/#{lib}"}