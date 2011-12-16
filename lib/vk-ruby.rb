require 'rubygems'
require 'net/https'
require 'transformer'
require 'yaml'
require 'yajl/json_gem'

module VK; end

%w(core secure serverside standalone vk_exception).each do |lib|
  require "vk-ruby/#{lib}"
end