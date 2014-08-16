# Logging middleware
#
# @see http://rubydoc.info/gems/faraday

class  VK::MW::VkLogger < Faraday::Middleware
  extend Forwardable

  # Default request/response formatter
  DEFAULT_FORMATTER = ->(data) { data.inspect }

  dependency 'cgi'
  dependency 'logger'

  def_delegators :@logger, :debug, :warn, :error, :info

  def initialize(app, options = {})
    super(app)
    @logger = options.fetch(:logger, Logger.new(STDOUT))
    @request_formatter = options.fetch(:request, DEFAULT_FORMATTER)
    @response_formatter = options.fetch(:response, DEFAULT_FORMATTER)
    @error_formatter = options.fetch(:error, DEFAULT_FORMATTER)
  end

  def call(env)
    begin
      case env.body
      when String
       data = { method: api_method(env), params: api_params(env) }
      when Faraday::CompositeReadIO
       data = { url: env.url.to_s, file: true }
      else
       data = { url: env.url.to_s, params: api_params(env) }
      end

      info @request_formatter.call(data)

      result = @app.call(env)

      info @response_formatter.call({
        method: api_method(env),
        params: CGI.unescape(env.body)
      })

      result 
    rescue => ex
      error @error_formatter.call(ex)
      raise ex
    end
  end

  private

  def api_method(env)
    env.url.path.split('/').reject(&:empty?).last
  end

  def api_params(env)
    CGI.unescape(env.method == :get ? env.url.query : env.body)
  end

end
