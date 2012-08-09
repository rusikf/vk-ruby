# encoding: UTF-8

require 'faraday'
require 'faraday_middleware'
require 'transformer'
require 'multi_json'
require 'yaml'
require 'cgi'
require 'forwardable'

FaradayMiddleware::ParseJson.define_parser do |body|
  MultiJson.load(body)
end

%w(middleware/validate_utf middleware/normalize_utf configurable core secure serverside standalone vk_exception).each{|lib| require "vk-ruby/#{lib}"}