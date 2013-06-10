# encoding: UTF-8

class  VK::MW::Response::VkLogger < Faraday::Response::Middleware
  extend Forwardable

  dependency 'cgi'
  dependency 'forwardable'

  def_delegators :@logger, :debug, :debug?, :error?, :info, :warn, :error, :fatal

  def initialize(app, logger = nil)
    super(app)

    @logger = logger || begin
      require 'logger'
      ::Logger.new(STDOUT)
    end
  end

  def call(env)
    if debug?
      method = env[:url].path.split('/').reject(&:empty?).last

      params = if env[:method] == :get
                 CGI.unescape env[:url].query
               else env[:method]
                 CGI.unescape env[:body]
               end

      debug "request #{method} -> #{params}"
    end

    super
  end

  def on_complete(env)
    if debug?
      method = env[:url].path.split('/').reject(&:empty?).last

      params = CGI.unescape env[:body]

      debug "response #{method} <- #{env[:status].to_s.upcase} : #{params}"
    end
  end

end
