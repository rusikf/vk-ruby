require 'helpers'

describe VK::AuthorizationError, type: :exception do 
  let(:api_method)  { 'users.get' }
  let(:url)         { URI.parse("https://oauth.vk.com/" << api_method) }
  let(:error)       { 'test' }
  let(:description) { 'error description' }

  let(:body) {
    { 
      'error' => error,
      'error_description' => description
    }
  }

  it { exception.error.should eq(error) }
  it { exception.description.should eq(description) }
  
  it { exception.to_s.should include(error) }
  it { exception.to_s.should include(description) }
end