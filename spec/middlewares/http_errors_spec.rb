require 'helpers'

describe VK::MW::HttpErrors, type: :middleware do
  let(:status) { 500 }

  it { expect{ process({}) }.to raise_error(VK::BadResponse) }
end
