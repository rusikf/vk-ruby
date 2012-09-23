# encoding: UTF-8

# @author Andrew Zinenko

require 'faraday'
require 'faraday_middleware'
require 'transformer'
require 'multi_json'
require 'yaml'
require 'cgi'
require 'forwardable'
require 'openssl'

# Register multi_json parser.
FaradayMiddleware::ParseJson.define_parser do |body|
  MultiJson.load(body)
end

%w(validate_utf normalize_utf vk_logger).each{|lib| require "vk-ruby/middleware/response/#{lib}"}

%w(configurable core secure serverside standalone vk_exception version).each{|lib| require "vk-ruby/#{lib}"}