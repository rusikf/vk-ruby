# encoding: UTF-8

require 'iconv'

module VK::Core

  attr_accessor :app_id, :access_token, :logger, :verbs, :attempts
  attr_reader   :expires_in

  def app_id
    @app_id ? @app_id : VK.const_defined?(:APP_ID) ? VK::APP_ID : nil
  end

  def access_token
    @access_token ? @access_token : VK.const_defined?(:ACCESS_TOKEN) ? VK::ACCESS_TOKEN : nil
  end

  def logger
    @logger ? @logger : VK.const_defined?(:LOGGER) ? VK::LOGGER : nil
  end

  def verbs
    @verbs ? @verbs : VK.const_defined?(:VERBS) ? VK::VERBS : :post
  end

  def attempts
    @attempts ? @attempts : VK.const_defined?(:ATTEMPTS) ? VK::ATTEMPTS : 3
  end

  [:base, :ext, :secure].each do |name|
    class_eval(<<-EVAL, __FILE__, __LINE__)
      def #{name}_api
        @@#{name}_api ||= YAML.load_file( File.expand_path( File.dirname(__FILE__) + "/api/#{name}.yml" ))
      end
    EVAL
  end

  private

  def vk_call method_name, arr
    params = arr.shift || {}
    params[:access_token] ||= self.access_token
    response = request(params.delete(:verbs), "/method/#{method_name}", params)
    raise VK::ApiException.new(method_name, response)  if response['error']
    response['response']
  end

  def request verbs, path, options = {}
    params = connection_params(options)
    attempts = params.delete(:attempts) || self.attempts
    http_verbs = verbs || self.verbs

    case http_verbs
    when :post then body = http_params(options)
    when :get  then path << '?' << http_params(options)
    else raise 'Not suported http verbs'
    end

    response = connection(params).request(http_verbs, path, {}, body, attempts)
    raise VK::BadResponseException.new(response, verbs, path, options) if response.code.to_i >= 500
    parse response.body
  end

  def connection params
    VK::Connection.new params
  end

  def http_params hash
    hash.map{|k,v| "#{CGI.escape k.to_s }=#{CGI.escape v.to_s }" }.join('&')
  end

  def connection_params options
       {:host => (options.delete(:host) || 'api.vk.com'),
        :port => (options.delete(:port) || 443),
      :logger => (options.delete(:logger) || self.logger)}
  end

  def parse string
    attempt = 1

    # begin
      ::JSON.parse(string)
    # rescue ::JSON::ParserError => exxxc
    #   logger.error "Invalid encoding" if logger

    #   if attempt == 1
    #     string = ::Iconv.iconv("UTF-8//IGNORE", "UTF-8", (string + " ")).first[0..-2]
    #     string.gsub!(/[^а-яa-z0-9\\\'\"\,\[\]\{\}\.\:\_\s\/]/i, '?')
    #     string.gsub!(/(\s\s)*/, '')
    #   else 
    #     raise ::VK::ParseException, string
    #   end

    #   attempt += 1; retry
    end
  end
  
end