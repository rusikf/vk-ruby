# encoding: utf-8

$:.push File.expand_path('../lib', __FILE__)
require  'vk-ruby/version'

Gem::Specification.new do |gem|
  gem.name = "vk-ruby"
  gem.version = VK::VERSION
  gem.authors = ["Andrew Zinenko"]
  gem.email = "zinenkoan@gmail.com"
  gem.summary = "Ruby wrapper for vk.com API"
  gem.description = " Ruby wrapper for vk.com API "
  gem.homepage = "http://github.com/zinenko/vk-ruby"
  gem.date = Time.now.strftime '%Y-%m-%d'
  gem.licenses = ["MIT"]

  gem.extra_rdoc_files = ["LICENSE.txt", "README.md" ]

  gem.add_runtime_dependency 'transformer',        '~> 0.2.2'
  gem.add_runtime_dependency 'attr_configurable',  '~> 0.1.0'
  gem.add_runtime_dependency 'multi_json',         '~> 1.3.6'
  gem.add_runtime_dependency 'faraday',            '~> 0.8.4'
  gem.add_runtime_dependency 'faraday_middleware', '~> 0.8.8'
  gem.add_runtime_dependency 'unicode_utils',      '~> 1.3.0'
  gem.add_runtime_dependency 'jruby-openssl',      '~> 0.7.7' if RUBY_PLATFORM == 'java'

  gem.add_development_dependency 'rake',      '~> 0.9'
  gem.add_development_dependency 'minitest',  '~> 2.8'
  gem.add_development_dependency 'webmock',   '~> 1.0'
  gem.add_development_dependency 'oj',        '~> 1.0.6'       unless RUBY_PLATFORM == 'java'
  gem.add_development_dependency 'yajl-ruby', '~> 1.1.0'       unless RUBY_PLATFORM == 'java'
  gem.add_development_dependency 'json_pure', '~> 1.7.4'
  gem.add_development_dependency 'eventmachine',    '~> 1.0.0' unless RUBY_PLATFORM == 'java'
  gem.add_development_dependency 'em-synchrony',    '~> 1.0.2' unless RUBY_PLATFORM == 'java'
  gem.add_development_dependency 'em-http-request', '~> 1.0.3' unless RUBY_PLATFORM == 'java'
  gem.add_development_dependency 'patron',    '~> 0.4.18'      unless RUBY_PLATFORM == 'java'
  gem.add_development_dependency 'typhoeus',  '~> 0.4.2'       if !defined?(RUBY_ENGINE) || RUBY_ENGINE != 'rbx'
  gem.add_development_dependency 'net-http-persistent', '2.7'

  gem.require_paths = ['lib']
  gem.executables << 'vk'
  gem.required_rubygems_version = Gem::Requirement.new('>= 1.3.6')

  gem.files = `git ls-files`.split("\n")
  gem.test_files = `git ls-files -- tests/*`.split("\n")
end