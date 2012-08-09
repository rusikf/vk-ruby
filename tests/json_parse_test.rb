require File.expand_path('../helpers', __FILE__)

class JsonParseTest < MiniTest::Unit::TestCase

  BAD_PROFILES = 21774501...21774512

  def setup
    @app = VK::Standalone.new app_id: '2878250',
                          app_secret: 'YUvaf67VoJgCuCvm2Rgj',
                        access_token: '7bde41fd7eb64c047eb64c04207e9da72e77eb07eb34c1226a10c40cb3418bc'
                        
    @fields = %w[uid first_name last_name nickname screen_name bdate sex city country photo_big has_mobile contacts education rate relation counters]
    
    WebMock.reset!
    WebMock.allow_net_connect!
  end

  [:json_gem, :json_pure, :oj, :yajl].each do |engine|
    defined_method "test_#{engine}" do 

    MultiJson.engine = engine

    BAD_PROFILES.each do |uid|
      assert lambda{|i|
        begin
          @app.getProfiles(uids: i, fields: @fields.join(','), verb: :get); true
        rescue Faraday::Error::ParsingError => ex
          false
        end
      }.call(uid), "#{engine} parsing error"
    end

    end
  end

end