require 'helpers'

describe VK::APIError, type: :exception do
  let(:api_method)  { 'users.get' }
  let(:url)         { URI.parse("https://api.vk.com/#{ api_method }") }
  let(:code)        { 1 }
  let(:description) { 'error description' }

  let(:body) {
    { 
      'error' => { 
        'error_code' => code, 
        'error_msg' =>  description,
        'request_params' => request_params
      }
    }
  }

  let(:request_params) {
    [
      { 'key' => 'key1', 'value' => 'value1' }, 
      { 'key' => 'key2', 'value' => 'value2' }
    ]
  }

  it { exception.method.should eq(api_method) }
  it { exception.code.should eq(code) }
  it { exception.description.should eq(description) }
  it { exception.request_params.should eq(request_params.inject({}) {|a, hash| a[hash['key']] = hash['value']; a }) }

  it { exception.to_s.should include(code.to_s) }
  it { exception.to_s.should include(api_method.to_s) }
  it { exception.to_s.should include(description.to_s) }
end