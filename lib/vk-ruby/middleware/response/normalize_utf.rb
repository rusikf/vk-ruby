# encoding: UTF-8 

class VK::MW::Response::NormalizeUtf < Faraday::Response::Middleware

  dependency 'unicode_utils'

  attr_accessor :ntype

  def initialize(app, t = :nfkd)
    self.ntype = t
    super(app)
  end

  def call(environment)
    @app.call(environment).on_complete do |env|
      env[:body] = UnicodeUtils.send(ntype, env[:body])
      env
    end
  end

end