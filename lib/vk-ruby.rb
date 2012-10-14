# encoding: UTF-8

# @title Ruby wrapper for vk.com API.
# @author Andrew Zinenko

require 'faraday'
require 'faraday_middleware'
require 'multi_json'
require 'attr_configurable'

# Register multi_json parser.
FaradayMiddleware::ParseJson.define_parser do |body|
  MultiJson.load(body) unless body.strip.empty?
end

%w(namespace utils middleware/middleware core application secure serverside standalone vk_exception version).each { |lib| require "vk-ruby/#{lib}" }