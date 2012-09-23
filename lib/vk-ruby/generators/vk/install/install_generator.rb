module Vk
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    # Creates the initialize file.
    def generate_initializer
      copy_file 'initializer.rb', 'config/initializers/vk-ruby.rb'
    end
  end
end