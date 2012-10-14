# encoding: UTF-8

module VK
  module Middleware
    module Response
    end
  end

  MW = Middleware
end

%w(validate_utf normalize_utf vk_logger http_errors api_errors).each { |lib| require "vk-ruby/middleware/response/#{lib}"}

Faraday.register_middleware :response,   http_errors: VK::MW::Response::HttpErrors
Faraday.register_middleware :response,    api_errors: VK::MW::Response::ApiErrors
Faraday.register_middleware :response,     vk_logger: VK::MW::Response::VkLogger
Faraday.register_middleware :response, normalize_utf: VK::MW::Response::NormalizeUtf
Faraday.register_middleware :response,  validate_utf: VK::MW::Response::ValidateUtf