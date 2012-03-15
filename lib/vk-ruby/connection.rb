require 'cgi'

class VK::Connection

	def initialize options = {}
		options.each{|attr, value| instance_variable_set("@#{attr}", value) }

		reset!
	end

	def request(verbs, path, data)
		@logger.debug "Request #{verbs} #{path} #{data}" if @logger

		params = http_params(data)

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
		reset!
		(@attempts ||= 3) <= 0 ? raise : (@attempts -= 1; retry)
	end

	private

	def reset!
		@http = Net::HTTP.new @host, @port

		if @logger && @logger.debug?
			@http.set_debug_output @logger 
		end
		
		if @port == 443
			@http.use_ssl = true
			@http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		end

		@http 
	end

	def http_params(hash)
		hash.map{|k,v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}"}.join('&')
	end

end