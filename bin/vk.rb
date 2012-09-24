#!/usr/bin/env ruby
# encoding: utf-8

require 'optparse'
require 'logger'

$:.unshift File.expand_path('../../lib', __FILE__)

require 'vk-ruby'

__options__ = {}

optparser = OptionParser.new do |opts|
  opts.banner = 'Usage: %s [options]' % $0

  opts.on_tail '-h', '--help', 'Display this help and exit' do
    puts opts
    exit
  end

  opts.on_tail '-v', '--version', 'Output version infomation and exit' do
    puts 'VK-RUBY v%s' % VK::VERSION
    puts 'Copyright (c) 2011-2012 Andrew Zinenko'
    exit
  end

  opts.on_tail '-e', '--eval [code]', 'Evaluate the given code and exit' do |e|
    __options__[:eval] = e
  end

  opts.on_tail '-a', '--access_token [token]', 'Your access token' do |a|
    __options__[:access_token] = a
  end

  opts.on_tail '-t', '--type [type]',[:serverside, :standalone, :secure], 'Application type' do |t|
    __options__[:type] = t
  end

  opts.on_tail '-i', '--id [id]', 'Application ID' do |i|
    __options__[:id] = i
  end

  opts.on_tail '-s', '--secret [secret]', 'Application secret' do |s|
    __options__[:secret] = s
  end

  opts.on_tail '-l', '--logfile', 'Logfile' do |l|
    __options__[:logfile] = l
  end

  opts.on_tail '-T', '--types', 'List application types' do |t|
    puts %w[serverside standalone secure]
    exit
  end

end

optparser.tap{ |opts| opts.parse! }

# puts __options__

def vk
  @vk
end

_app_params = {}

_app_params[:app_id] = __options__[:id] || ''
_app_params[:access_token] = __options__[:access_token] || nil
_app_params[:logger] = Logger.new(__options__[:logfile] || nil)
_app_params[:app_secret] = __options__[:secret] || ''

case (__options__[:type].downcase.to_sym rescue nil)
when :standalone
  @vk = VK::Standalone.new _app_params
when :secure
  @vk = VK::Secure.new _app_params
else
  @vk = VK::Serverside.new _app_params
end

if __options__[:eval]
  eval(__options__[:eval], binding, __FILE__, __LINE__)
  exit
else
  require 'vk-ruby/core_ext/irb'
  IRB.start_session(binding)
  exit
end