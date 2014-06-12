module ErrorGroup
  
  def self.included(base)
    base.let(:options) { Hash.new }
    base.let(:url)     { URI.parse('https://api.vk.com') }
    base.let(:status)  { 200 }
    base.let(:headers) { Hash.new }
    base.let(:body)    { }
    
    base.let(:env) {
      Faraday::Env.new.tap { |env|
        env.status = status
        env.url = url
        env.response_headers = Faraday::Utils::Headers.new(headers)
        env.body = body
      }
    }

    base.let(:exception) { described_class.new(env) }
  end
  
  
end