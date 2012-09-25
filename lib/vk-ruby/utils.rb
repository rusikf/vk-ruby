# encoding: UTF-8

module VK
  module Utils

    # Prints a deprecation message.
    def self.deprecate(message)
      Kernel.warn "VK-RUBY: Deprecation warning: " + message
    end

  end
end