module MiddlewareGroup

  def self.included(base)
    base.let(:options) { Hash.new }
    base.let(:url)     { URI.parse('https://api.vk.com') }
    base.let(:status)  { 200 }
    base.let(:headers) { Hash.new }
    
    base.let(:middleware) do
      if described_class.method(:new).parameters.count == 2
        described_class.new ->(env) { Faraday::Response.new(env) }, options
      else
        described_class.new ->(env) { Faraday::Response.new(env) }
      end
    end
  end

  def process(body)
    middleware.call Faraday::Env.new.tap{ |env|
      env.status = status
      env.url = url
      env.response_headers = Faraday::Utils::Headers.new(headers)
      env.body = body
    }
  end
  
end