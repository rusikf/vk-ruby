module VK
  module Core
    attr_accessor :app_id, :access_token, :expires_in, :logger, :verbs, :attempts, :headers

    private

    def vk_call(method_name,p)  
      params = p.shift || {}
      raise 'undefined access token' unless params[:access_token] ||= @access_token

      response = request( :verbs => params.delete(:verbs),
                          :path => [nil, 'method', method_name].join('/'),
                          :params => params)

      raise VK::VkException.new(method_name, response) if response['error']
      response['response']
    end

    def request(options, &block)
      http_verbs = (options.delete(:verbs) || @verbs || :post).to_sym
      path = options.delete(:path)
      body = options.delete(:params)

      params = {:host => 'api.vk.com', 
                :port => 443, 
                :logger => @logger, 
                :attempts => @attempts, 
                :headers => @headers }.merge(options)

      http = VK::Connection.new(params)
      response = http.request(http_verbs, path, body, &block)
      VK::JSON.load(response.body)
    end

    [:base, :ext, :secure].each do |name|
      class_eval(<<-EVAL, __FILE__, __LINE__)
        def #{name}_api
          @@#{name}_api ||= YAML.load_file( File.expand_path( File.dirname(__FILE__) + "/api/#{name}.yml" ))
        end
      EVAL
    end

  end
end