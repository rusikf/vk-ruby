require 'helpers'

describe VK::BadResponse, type: :exception do 
  let(:status) { 500 }

  it { exception.status.should eq(status) }
  
  it { exception.to_s.should include(status.to_s) }
end