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
      
  gem.add_runtime_dependency 'transformer', '~> 0.2.2'
  gem.add_runtime_dependency 'oj', '~> 1.0.6'

  gem.add_development_dependency 'rake', '~> 0.9'
  gem.add_development_dependency 'minitest', '~> 2.8'
  gem.add_development_dependency 'webmock', '~> 1.0'

  gem.require_paths = ['lib']
  gem.required_rubygems_version = Gem::Requirement.new('>= 1.3.6')

  gem.files = `git ls-files`.split("\n")
  gem.test_files = `git ls-files -- tests/*`.split("\n") 
end