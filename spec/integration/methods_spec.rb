require 'helpers'

describe 'API method calling', type: :integration do

  context 'without authorization' do
    it '#users.get' do
      result = application.users.get(user_ids: 1).first

      expect(result).to be_a(Enumerable)
      expect(result['id']).to eq(1)
      expect(result['last_name']).not_to be_empty
      expect(result['first_name']).not_to be_empty
    end
  end

  context 'with authorization' do
    before(:all) { authorizate! }

    it '#users.get' do
      result = application.users.get(user_ids: 1).first

      expect(result).to be_a(Enumerable)
      expect(result['id']).to eq(1)
      expect(result['last_name']).not_to be_empty
      expect(result['first_name']).not_to be_empty
    end
  end

end