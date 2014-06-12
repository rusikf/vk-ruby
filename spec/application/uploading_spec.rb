require 'helpers'

describe VK::Uploading, type: :application do

  before { stub_uploading! }
  
  describe "#upload" do
    let(:path)         { double("File path") }
    let(:mime)         { double("Mime type") }
    let(:io)           { double("Uploading file IO") }
    let(:body)         { double("Response body") }
    let(:response)     { double("Response", body: body) }
    let(:uploading_io) { double("Faraday::UploadIO") }
    let(:url)          { 'https://server.vk.com' }
    
    before do
      Faraday::UploadIO.stub(:new).and_return(uploading_io)
      subject.stub(:request).and_return(response)
    end
    
    it { expect { subject.upload }.to raise_error(ArgumentError) }
    
    context 'with Hash params' do
      let(:params) do
        { 
          key1: [path, mime],
          key2: [io, mime, path]
        }
      end

      it "uploads the files as hash keys" do
        expect(Faraday::UploadIO).to receive(:new).with(path, mime, nil)
        expect(Faraday::UploadIO).to receive(:new).with(io, mime, path)
        expect(subject).to receive(:request).with(key1: uploading_io, key2: uploading_io)

        subject.upload(url, params).should eq(body)
      end
    end

    context 'with Array params' do
      let(:params) do
        [
          [path, mime],
          [io, mime, path]
        ]
      end

      it "uploads the files as file1, file2 etc" do
        expect(Faraday::UploadIO).to receive(:new).with(path, mime, nil)
        expect(Faraday::UploadIO).to receive(:new).with(io, mime, path)
        expect(subject).to receive(:request).with(file1: uploading_io, file2: uploading_io)

        subject.upload(url, params).should eq(body)
      end
    end
    
  end

end