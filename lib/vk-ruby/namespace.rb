# encoding: UTF-8

module VK
  module Namespace

    attr_reader :namespace

    def method_link
      @method_link ||= self.method(:vk_call)
    end

    def method_missing(method_name, *args, &block)
      full_method_name = self.namespace ? [self.namespace, camelize(method_name) ].join('.') : camelize(method_name)

      # puts [full_method_name, args].inspect

      method_link.call(full_method_name, args.first)
    end

    private

    def init_namespaces(names)
      names.each do |name|
        add_method name do
          instance_variable_get("@#{name}") || instance_variable_set("@#{name}", Object.new(name, method_link))
        end
      end
    end

    def add_method(name, &block)
      metaclass.send(:define_method, name, block)
    end

    def metaclass
      class << self; self; end
    end

    # camelize('get_profiles')
    # => 'getProfiles'

    def camelize(name)
      words = name.to_s.split('_')
      first_word = words.shift

      words.each{|word| word.sub! /^[a-z]/, &:upcase }

      words.unshift(first_word).join
    end

    class Object
      include VK::Namespace

      def initialize(parent_namespace, method_link)
        @namespace, @method_link = parent_namespace, method_link
      end
    end

  end
end