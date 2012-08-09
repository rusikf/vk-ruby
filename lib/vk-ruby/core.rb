# encoding: UTF-8

module VK::Core
  extend ::VK::Configurable
  extend Forwardable

  attr_accessor :faraday_middleware

  attr_configurable :app_id, :access_token, :ca_path, :ca_file, :verify_mode, :logger, :proxy

  attr_configurable :verb,            default: :post
  attr_configurable :attempts,        default: 5
  attr_configurable :timeout,         default: 2
  attr_configurable :open_timeout,    default: 3
  attr_configurable :adapter,         default: Faraday.default_adapter

  def_delegators :logger, :debug, :info, :warn, :error, :fatal, :level, :level=

  [:base, :ext, :secure].each do |name|
    class_eval(<<-EVAL, __FILE__, __LINE__ + 1)
      def #{name}_api
        @@#{name}_api ||= YAML.load_file( File.expand_path( File.dirname(__FILE__) + "/api/#{name}.yml" ))
      end
    EVAL
  end

  def vk_call(method_name, arr)
    response = request("/method/#{method_name}", (arr.shift || {}))

    raise VK::ApiException.new(method_name, response.body) if response.body['error']

    response.body['response']
  end

  private

  def request(path, options = {})
    attempts = options.delete(:attempts) || self.attempts

    host = options.delete(:host)  || 'https://api.vk.com'
    verb = (options.delete(:verb) || self.verb).downcase.to_sym

    options[:access_token] ||= self.access_token if host == 'https://api.vk.com'

    request_options = {params: {}}

    case verb
    when :post
      body = encode_params(options)
    when :get
      path << '?' << encode_params(options)
      body = {}
    else raise 'Not supported http verbs'
    end

    response = Faraday.new(host, request_options, &faraday_middleware).send(verb, path, body)

    raise VK::BadResponseException.new(response, verb, path, options) if response.status.to_i != 200

    response
  end

  def faraday_middleware
    @faraday_middleware ||= proc do |faraday|
      faraday.request  :url_encoded
      
      faraday.response :json, content_type: /\bjson$/
      faraday.response :xml,  content_type: /\bxml$/

      faraday.response :normalize_utf
      faraday.response :validate_utf
      
      faraday.adapter  self.adapter
    end
  end

  def encode_params(params)
    params.map do |key, value|
      value = MultiJson.dump(value) unless value.is_a?(String) || value.is_a?(Symbol)
      "#{key}=#{CGI.escape value.to_s}"
    end.join("&")
  end
  
end