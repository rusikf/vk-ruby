require 'rubygems'
require 'net/https'
require 'transformer'
require 'json'
require 'yaml'

%w(core secure serverside standalone vk_exception).each do |lib|
  require "vk-ruby/#{lib}"
end

module VK; end

# JSON Parser for VK-RUBY.
#
# If it's possible, please include Yajl to your environment.

VK::JSON = begin
  require 'yajl'
  ::Yajl
rescue LoadError
  require 'json'
  ::JSON
end