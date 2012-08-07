# encoding: UTF-8

require 'faraday'
require 'faraday_middleware'
require 'cgi'
require 'transformer'
require 'yaml'
require 'multi_json'
require 'forwardable'

module VK
end

%w(configurable core secure serverside standalone vk_exception).each{|lib| require "vk-ruby/#{lib}"}