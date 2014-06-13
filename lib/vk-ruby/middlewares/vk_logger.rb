# encoding: UTF-8

class  VK::MW::VkLogger < Faraday::Middleware
  extend Forwardable

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
      data = case env.body
        when String
         data = {
           method: env.url.path.split('/').reject(&:empty?).last,
           params: CGI.unescape(env.method == :get ? env.url.query : env.body)
         }
        when Faraday::CompositeReadIO
         data = {
           url: env.url.to_s,
           file: true
         }
        else
         data = {
           url: env.url.to_s,
           params: CGI.unescape(env.method == :get ? env.url.query : env.body)
         }
        end

      info @request_formatter.call(data)
      result = @app.call(env)

      info @response_formatter.call({
        method: env.url.path.split('/').reject(&:empty?).last,
        params: CGI.unescape(env.body)
      })

      result 
    rescue => ex
      @logger.error @error_formatter.call(ex)
      raise ex
    end
  end

end
