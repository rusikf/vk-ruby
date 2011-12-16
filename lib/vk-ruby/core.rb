module VK
  module Core
    attr_accessor :app_id, :access_token, :user_id, :expires_in, :debug, :logger

    def vk_call(method_name,p)  
      params = p[0] ||= {}
      raise 'undefined access token' unless params[:access_token] ||= @access_token

      begin
        resp = request(:path => "/method/#{method_name}", :params => params)  
        result = JSON.parse(resp.body)
      rescue Exception => info
        puts resp.inspect
        puts info.inspect
        raise
      end
      raise VK::VkException.new(method_name,result) if result['error']

      result['response']
    end

    private

    # def json(string)
    #   return JSON.parse(string) rescue raise string.inspect
    # end

    def request(p={})
      http.get( p[:path] + "?" + (p[:params].map{|k,v| "#{k}=#{v}" }).join('&') )
    end

    def http(p={})
      prms = ({:host => 'api.vk.com', :port => 443, :ssl => true }).merge p
      net = Net::HTTP.new prms[:host], prms[:port]
      net.set_debug_output @logger if @logger && @debug
      unless  prms[:ssl] == false
        net.use_ssl =  true
        net.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      net
    end

    def base_api
      @@base_api ||= YAML.load_file( File.expand_path( File.dirname(__FILE__) + "/api/base.yml" ))
    end

    def ext_api
      @@ext_api ||= YAML.load_file( File.expand_path( File.dirname(__FILE__) + "/api/ext.yml" ))
    end

    def secure_api
      @@secure_api ||= YAML.load_file( File.expand_path( File.dirname(__FILE__) + "/api/secure.yml" ))
    end
  end
end