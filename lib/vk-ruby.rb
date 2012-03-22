# encoding: UTF-8

require 'net/https'
require 'cgi'
require 'transformer'
require 'yaml'
require 'oj'

module VK
end

%w(connection core secure serverside standalone vk_exception).each{|lib| require "vk-ruby/#{lib}"}