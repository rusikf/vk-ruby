# encoding: UTF-8

UTF8REGEX = /[^a-z0-9а-яА-Я\\\'\"\,\[\]\{\}\.\:\_\s\/]/xui
require 'iconv'

module VK::Core
  attr_accessor :app_id, :access_token, :expires_in, :logger, :verbs, :attempts

  def execute(*args, &block)
    params = p.shift || {}
    raise 'undefined access token' unless params[:access_token] ||= @access_token

    if block_given?
      api = VK::Executable.new args
      vk_script = block.binding(api).call.vk_script
      vk_call 'execute', vk_script
    else
      vk_call 'execute', args
    end
  end

  # execute :acces_token => 'token' do |api, result|
  #   var.profiles = api.getProfiles(:uids => 1..100)
  #   var.profiles += api.getProfiles(:uids => 100...200)
  #   {:result => var.profiles}
  # end

  private

  def vk_call(method_name,p)  
    params = p.shift || {}
    raise 'undefined access token' unless params[:access_token] ||= @access_token

    response = request( :verbs => params.delete(:verbs),
                        :path => [nil, 'method', method_name].join('/'),
                        :params => params)

    raise VK::Exception.new(method_name, response) if response['error']
    response['response']
  end

  def request(options, &block)
    http_verbs = (options.delete(:verbs) || @verbs || :post).to_sym
    path = options.delete(:path)
    body = options.delete(:params)

    params = {:host => 'api.vk.com', 
              :port => 443, 
              :logger => @logger, 
              :attempts => @attempts}.merge(options)

    response = VK::Connection.new(params).request(http_verbs, path, body, &block)

    begin
      result = JSON.parse(response)
    rescue JSON::ParserError, Yajl::ParseError => e
      @logger.error "Invalid encoding" if @logger
      response = valid_utf8(response)     
      result = JSON.parse(response)
    end

    result
  end

  def save_to_file(file_name, string)
    aFile = File.new("bad_string.txt", "wb")
    aFile.write(string)
    aFile.close
  end

  def valid_utf8(string)
    #save_to_file('bad_string.json', string)
    string = ::Iconv.iconv("UTF-8//IGNORE", "UTF-8", (string + " ") ).first[0..-2]
    string.gsub!(UTF8REGEX,'')
    string
  end

  [:base, :ext, :secure].each do |name|
    class_eval(<<-EVAL, __FILE__, __LINE__)
      def #{name}_api
        @@#{name}_api ||= YAML.load_file( File.expand_path( File.dirname(__FILE__) + "/api/#{name}.yml" ))
      end
    EVAL
  end
  
end