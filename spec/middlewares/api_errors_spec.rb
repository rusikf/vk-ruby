require 'helpers'

describe VK::MW::APIErrors, type: :middleware do
  
  context VK::APIError do
    let(:data) {
      { 
        'error' => { 
          'error_code' => 'foo', 
          'error_msg' =>  'bar' 
        }
      }
    }

    it { expect{ process(data) }.to raise_error(VK::APIError) }
  end

  context VK::AuthorizationError do
    let(:url) { URI.parse('http://oauth.vk.com/access_token') }

    let(:data) {
      { 
        'error' => 'foo',
        'error_description' => 'bar'
      }
    }

    it { expect{ process(data) }.to raise_error(VK::AuthorizationError) }
  end

end
