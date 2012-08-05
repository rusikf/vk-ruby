# encoding: UTF-8

module VK::Core
  extend ::VK::Configurable

  attr_accessor :faraday_middleware

  attr_configurable :app_id, :access_token, :ca_path, :ca_file, :verify_mode, :logger, :proxy

  attr_configurable :verbs,           default: :post
  attr_configurable :attempts,        default: 5
  attr_configurable :timeout,         default: 2
  attr_configurable :open_timeout,    default: 3
  attr_configurable :default_adapter, default: Faraday.default_adapter

  [:base, :ext, :secure].each do |name|
    class_eval(<<-EVAL, __FILE__, __LINE__ + 1)
      def #{name}_api
        @@#{name}_api ||= YAML.load_file( File.expand_path( File.dirname(__FILE__) + "/api/#{name}.yml" ))
      end
    EVAL
  end

  def vk_call(method_name, arr)
    response = request("/method/#{method_name}", (arr.shift || {}))

    raise VK::ApiException.new(method_name, response) if response['error']

    response['response']
  end

  private

  def request(path, options = {})
    options[:access_token] ||= self.access_token

    attempts = options.delete(:attempts) || self.attempts
    host = options.delete(:host) || 'https://api.vk.com'
    verb = (options[:verb] ||= self.verbs)

    case verb.downcase.to_sym
    when :post then body = encode_params(options)
    when :get  then path << '?' << encode_params(options)
    else raise 'Not suported http verbs'
    end

    request_options = {params: (verb == "get" ? params : {})}

    response = Faraday.new(host, request_options, &faraday_middleware)

    raise VK::BadResponseException.new(response, verbs, path, options) if response.code.to_i != 200

    response
  end

  def faraday_middleware
    @faraday_middleware ||= proc do
      faraday.request  :url_encoded
      faraday.response :logger  
      faraday.adapter  self.default_adapter
    end
  end

  def encode_params(params)
    params.map do |key, value|
      value = MultiJson.dump(value) unless value.is_a?(String)
      "#{key}=#{CGI.escape value}"
    end.join("&")
  end
  
end