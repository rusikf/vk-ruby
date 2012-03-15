# encoding: UTF-8

require 'iconv'

module VK::Core
  attr_accessor :app_id, :access_token, :expires_in, :logger, :verbs, :attempts

  private

  def vk_call method_name, arr
    params = arr.shift || {}
    raise 'undefined access token' unless params[:access_token] ||= @access_token

    response = request(params.delete(:verbs), "/method/#{method_name}", params)

    raise VK::Exception.new(method_name, response) if response['error']
    response['response']
  end

  def request verbs, path, options = {}
    params = connection_params(options)

    attempts = params.delete :attempts
    http_verbs = (verbs || @verbs || :post).to_sym

    case http_verbs
      when :post
        body = http_params(options)
      when :get
        path << '?' + http_params(options)
      else
        raise 'Not suported http verbs'
      end

    result = connection(params).request(http_verbs, path, {}, body, attempts)

    parse(result.body)
  end

  def connection params
    VK::Connection.new params
  end

  def http_params hash
    hash.map{|k,v| "#{CGI.escape k.to_s }=#{CGI.escape v.to_s }" }.join('&')
  end

  def connection_params options
       {:host => ('api.vk.com' || options.delete(:host)),
        :port => (443 || options.delete(:port)),
      :logger => (@logger || options.delete(:logger)),
    :attempts => (@attempts || options.delete(:attempts))}
  end

  def parse string
    attempt = 1

    begin
      ::JSON.parse(string)
    rescue ::JSON::ParserError => exxxc
      @logger.error "Invalid encoding" if @logger

      if attempt == 1
        string = ::Iconv.iconv("UTF-8//IGNORE", "UTF-8", (string + " ") ).first[0..-2]
        string.gsub! /[^A-za-z0-9а-яА-Я\\\'\"\,\[\]\{\}\.\:\_\s\/]/xui, ''
      else 
        raise ::VK::ResponseParse.new(exxxc)
      end

      attempt += 1; retry
    end
  end

  [:base, :ext, :secure].each do |name|
    class_eval(<<-EVAL, __FILE__, __LINE__)
      def #{name}_api
        @@#{name}_api ||= YAML.load_file( File.expand_path( File.dirname(__FILE__) + "/api/#{name}.yml" ))
      end
    EVAL
  end
  
end