require 'helpers'

describe VK::Application, type: :application do
  let(:application) { VK::Application.new }

  before do
    stub_request(:post, /api.vk.com\/method/ ).to_return({
      body: '{}',
      headers: {"Content-Type" => 'application/json'}
    })
  end

  context 'before call "is_app_user" API method' do
    it { expect(application.methods).to_not include(:is_app_user) }
    it { expect(application.methods).to_not include(:isAppUser) }

    context 'call "is_app_user" API method' do
      before { application.is_app_user }

      it { expect(application.methods).to include(:is_app_user) }
      it { expect(application.methods).to include(:isAppUser) }
    end
  end
end