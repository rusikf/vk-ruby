# encoding: UTF-8

module VK
  module Middleware
  end

  MW = Middleware
end

%w(vk_logger http_errors api_errors).each do |lib| 
  require "vk-ruby/middlewares/#{ lib }"
end

Faraday::Response.register_middleware \
    http_errors: -> { VK::MW::HttpErrors },
     api_errors: -> { VK::MW::APIErrors },
      vk_logger: -> { VK::MW::VkLogger }

# Register multi_json parser.
FaradayMiddleware::ParseJson.define_parser do |body|
  MultiJson.load(body) unless body.strip.empty?
end