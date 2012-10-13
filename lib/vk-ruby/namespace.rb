# encoding: UTF-8

module VK
  module Namespace

    # @private
    NAMES = [:users,
             :likes,
             :friends,
             :groups,
             :photos,
             :wall,
             :newsfeed,
             :notifications,
             :audio,
             :video,
             :docs,
             :places,
             :secure,
             :storage,
             :notes,
             :pages,
             :stats,
             :subscriptions,
             :widgets,
             :leads,
             :messages,
             :status,
             :polls,
             :account,
             :board,
             :fave,
             :auth,
             :ads,
             :orders]

    attr_reader :namespace

    NAMES.each do |name|
      define_method name do
        instance_variable_get("@#{name}") || instance_variable_set("@#{name}", Object.new(name, self.method_link))
      end
    end

    def method_link
      @method_link ||= self.method(:vk_call)
    end

    def method_missing(method_name, *args, &block)
      full_method_name = self.namespace ? [self.namespace, camelize(method_name) ].join('.') : camelize(method_name)
      method_link.call(full_method_name, args.first)
    end

    private

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