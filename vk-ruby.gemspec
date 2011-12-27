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
  gem.date = "2011-11-23"
  gem.licenses = ["MIT"]
    
  gem.extra_rdoc_files = ["LICENSE.txt", "README.md" ]
      
  gem.add_runtime_dependency 'transformer',   '~> 0.2.2'
  gem.add_runtime_dependency 'json',          '~> 1.6'   unless Object.const_defined?('RUBY_ENGINE') && RUBY_ENGINE =~ /jruby/
  gem.add_runtime_dependency 'jruby-openssl', '~> 0.7.4'     if Object.const_defined?('RUBY_ENGINE') && RUBY_ENGINE =~ /jruby/
  gem.add_runtime_dependency 'json-jruby',    '~> 1.1.7'     if Object.const_defined?('RUBY_ENGINE') && RUBY_ENGINE =~ /jruby/

  gem.add_development_dependency 'rake', '~> 0.9'
  gem.add_development_dependency 'minitest', '~> 2.8'
  gem.add_development_dependency 'yajl-ruby', '~> 1.0'
  gem.add_development_dependency 'webmock', '~> 1.0'

  gem.require_paths = ['lib']
  gem.required_rubygems_version = Gem::Requirement.new('>= 1.3.6')

  gem.files = `git ls-files`.split("\n")
  gem.test_files = `git ls-files -- tests/*`.split("\n") 
end