require 'helpers'

describe 'File uploading', type: :integration do
  let(:path) { File.expand_path('../../support/test.jpg', __FILE__) }
  let(:mime) { 'image/jpeg' }

  before(:all) { authorizate! }

  it 'docs uploading' do
    result = application.docs.getUploadServer
    
    expect(result).to be_a(Hash)
    expect(result['upload_url']).not_to be_nil
    
    result = application.upload result['upload_url'], file: [path, mime]

    expect(result).to be_a(Hash)
    expect(result['file']).not_to be_nil

    result = application.docs.save file: result['file'], title: 'test', tags: 'title'

    expect(result).to be_a(Enumerable)

    result.first.tap do |r|
      expect(r['id']).not_to be_nil
      expect(r['owner_id']).not_to be_nil
      expect(r['title']).not_to be_nil
      expect(r['size']).not_to be_nil
      expect(r['ext']).not_to be_nil
      expect(r['url']).not_to be_nil
    end
  end

end