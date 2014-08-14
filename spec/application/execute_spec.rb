require 'helpers'

describe VK::Application, type: :application do
  let(:application) { VK::Application.new }

  before do
    stub_request(:post, /api.vk.com\/method/ ).to_return({
      body: '{}',
      headers: {"Content-Type" => 'application/json'}
    })
  end

  context 'execute API method (with params)' do
    before { application.execute code: 'return 1' }

    it { WebMock.should have_requested(:post, 'https://api.vk.com/method/execute') }
  end

  context 'execute API namespace (without params)' do
    before { application.execute.proc_name }

    it { WebMock.should have_requested(:post, 'https://api.vk.com/method/execute.procName') }
  end
end
