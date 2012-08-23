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
  gem.add_runtime_dependency 'multi_json',         '~> 1.3.6'
  gem.add_runtime_dependency 'multi_xml',          '~> 0.5.1'
  gem.add_runtime_dependency 'faraday',            '~> 0.8.0'
  gem.add_runtime_dependency 'faraday_middleware', '~> 0.8.8'
  gem.add_runtime_dependency 'unicode_utils',      '~> 1.3.0'
  gem.add_runtime_dependency 'jruby-openssl',      '~> 0.7.7' if RUBY_PLATFORM == 'java'

  gem.add_development_dependency 'rake',      '~> 0.9'
  gem.add_development_dependency 'minitest',  '~> 2.8'
  gem.add_development_dependency 'webmock',   '~> 1.0'
  gem.add_development_dependency 'oj',        '~> 1.0.6' unless RUBY_PLATFORM == 'java'
  gem.add_development_dependency 'yajl-ruby', '~> 1.1.0' unless RUBY_PLATFORM == 'java'
  gem.add_development_dependency 'json_pure', '~> 1.7.4'

  gem.require_paths = ['lib']
  gem.required_rubygems_version = Gem::Requirement.new('>= 1.3.6')

  gem.files = `git ls-files`.split("\n")
  gem.test_files = `git ls-files -- tests/*`.split("\n")
end