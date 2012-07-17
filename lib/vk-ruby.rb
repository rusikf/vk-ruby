# encoding: UTF-8

require 'faraday'
require 'cgi'
require 'transformer'
require 'yaml'
require 'multi_json'

module VK
end

%w(configurable core secure serverside standalone vk_exception).each{|lib| require "vk-ruby/#{lib}"}