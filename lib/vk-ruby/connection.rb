class VK::Connection
  def initialize options = {}
    options.each{|attr, value| instance_variable_set("@#{attr}", value) }
    @http = create_connection
  end

  def request(verbs, path, data, &block)
    @logger.debug "Request #{verbs} #{path} #{data}" if @logger

    params = data.map{|k,v| "#{k}=#{v}"}.join('&')

    requester = Proc.new{
      case verbs
        when :get
          @http.get([path, params].join('?')).body
        when :post
          @http.post(path, params).body
        else
          raise 'Not suported http verbs'
        end
    }.call

  rescue Errno::EPIPE, Timeout::Error, Errno::EINVAL, EOFError
    @logger.error "Rrequest errors(#{@attempts})"if @logger
    @http = create_connection
    (@attempts ||= 3) <= 0 ? raise : (@attempts -= 1; retry)
  end

  private

    def create_connection
      net = Net::HTTP.new @host, @port

      net.set_debug_output @logger if @logger && @logger.debug?

      if @port == 443
        net.use_ssl = true
        net.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      net 
    end
    
end