# encoding: UTF-8

require 'iconv'

module VK::Core
  UTF8REGEX = /[^a-z0-9а-яА-Я\\\'\"\,\[\]\{\}\.\:\_\s\/]/xui

  attr_accessor :app_id, :access_token, :expires_in, :logger, :verbs, :attempts

  def execute(params, &block)
    if block_given?
      api = VK::Executable::Chain.new
      result = block.bind(api).call.to_vkscript
      vk_script = api.to_vkscript + result
      vk_call 'execute', [{:code => vk_script}.merge(params)]
    else
      vk_call 'execute', [params]
    end
  end

  # execute :acces_token => 'token' do
  #   var.profiles = api.getProfiles(:uids => 1..100)       # chain.push 'var profiles = API.getProfiles({'uids': [1,2,3,4,5..100]})'
  #   profiles += api.getProfiles(:uids => 100...200)       # chain.push 'profiles = profiles + API.getProfiles({'uids': [100..200]})'
  #   profiles                                              # + return profiles
  # end

  private

  def vk_call(method_name,p)  
    params = p.shift || {}
    raise 'undefined access token' unless params[:access_token] ||= @access_token

    response = request( :verbs => params.delete(:verbs),
                        :path => [nil, 'method', method_name].join('/'),
                        :params => params )

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

  def valid_utf8(string)
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