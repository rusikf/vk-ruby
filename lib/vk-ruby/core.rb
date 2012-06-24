# encoding: UTF-8

module VK::Core
  include Configurable

  attr_configurable :app_id, :access_token, :ca_path, :ca_file, :verify_mode, :logger, :proxy

  attr_configurable :verbs,        :post
  attr_configurable :attempts,     5
  attr_configurable :timeout,      2
  attr_configurable :open_timeout, 3

  [:base, :ext, :secure].each do |name|
    class_eval(<<-EVAL, __FILE__, __LINE__)
      def #{name}_api
        @@#{name}_api ||= YAML.load_file( File.expand_path( File.dirname(__FILE__) + "/api/#{name}.yml" ))
      end
    EVAL
  end

  # Call vk.com api method.
  #
  # @param method_name a vk.com api method name
  # @param arr a array of method params
  #
  # @example
  #   @application.vk_call('api_method_name', [{:a => 1, :b => "My String"}])
  #   => request to "https://api.vk.com/method/api_method_name?a=1&b=My+String"
  #
  # @return the vk.com api response hash

  def vk_call(method_name, arr)
    params = arr.shift || {}
    params[:access_token] ||= self.access_token

    response = request("/method/#{method_name}", params)

    if response['error'] 
      if response['error']['code'].to_i == 5
        raise VK::RevokeAccessException.new(method_name, response, params[:access_token])
      else
        raise VK::ApiException.new(method_name, response) if response['error']
      end
    end

    response['response']
  end

  private

  def request(path, options = {})
    attempts = params.delete(:attempts) || self.attempts
    verbs = params.delete(:verbs) || self.verbs
    params = self.params.merge(options)

    case verbs
    when :post then body = self.class.encode_params(options)
    when :get  then path << '?' << self.class.http_params(options)
    else raise 'Not suported http verbs'
    end

    response = connection(params).request(http_verbs, path, params, body, attempts)

    raise VK::BadResponseException.new(response, verbs, path, options) if response.code.to_i >= 500

    parse response.body 
  end

  # Encodes a given hash into a query string.
  #
  # @param params_hash a hash of values to CGI-encode and appropriately join
  #
  # @example
  #   VK::Core.encode_params({:a => 2, :b => "My String"})
  #   => "a=2&b=My+String"
  #
  # @return the appropriately-encoded string

  def self.encode_params(param_hash)
    ((param_hash || {}).sort_by{|k, v| k.to_s}.collect do |key_and_value|
      key_and_value[1] = MultiJson.dump(key_and_value[1]) unless key_and_value[1].is_a? String
      "#{key_and_value[0].to_s}=#{CGI.escape key_and_value[1]}"
    end).join("&")
  end
  
end