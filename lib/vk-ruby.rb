require 'rubygems'
require 'net/https'
require 'transformer'
require 'yaml'

module VK; end

# JSON Parser for VK-RUBY.
#
# If it's possible, please include Yajl to your environment.

begin
  require 'yajl/json_gem'
  rescue LoadError
  require 'json'
end

%w(core secure serverside standalone vk_exception).each do |lib|
  require "vk-ruby/#{lib}"
end