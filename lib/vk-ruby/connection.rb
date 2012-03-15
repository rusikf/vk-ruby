class VK::Connection
	attr_reader :http

  def initialize params = {}
    params.each do |attr, value| 
			instance_variable_set("@#{attr}", value)
		end

    reset!
  end

  def reset!
    @http = create_connection
  end

  def request(verb, path, options = {}, body = nil, attempts = 3)
	  begin
	    requester = proc {
	      request = request_method(verb).new(path, options)

	      if body
	        if body.respond_to?(:read)
	          request.body_stream = body
	        else
	          request.body = body
	        end
	        request.content_length = body.respond_to?(:lstat) ? body.stat.size : body.size
	      else
	        request.content_length = 0
	      end

	      http.request(request)
	    }

	    http.start &requester
	  rescue Errno::EPIPE, Timeout::Error, Errno::EINVAL, EOFError
	    reset!
	    attempts == 3 ? raise : (attempts += 1; retry)
	  end
  end

  private

  def request_method verb
    Net::HTTP.const_get(verb.to_s.capitalize)
  end

  def create_connection
    net = Net::HTTP.new(@host, @port)

    if @logger && @logger.debug?
			net.set_debug_output @logger 
		end
		
		if @port == 443
			net.use_ssl = true
			net.verify_mode = OpenSSL::SSL::VERIFY_NONE
		end

		net
  end

end