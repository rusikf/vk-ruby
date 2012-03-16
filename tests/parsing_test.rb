require File.expand_path('../helpers', __FILE__)

class ParsingTest < MiniTest::Unit::TestCase
  def setup
    @app = VK::Standalone.new :app_id => ''
    @fields = %w[uid first_name last_name nickname screen_name bdate sex city country photo_big has_mobile contacts education rate relation counters]
  end

  def test_bad_profiles
    WebMock.allow_net_connect!

    [22651572, 21774501].each do |uid|
      @app.getProfiles :uids => uid, :fields => @fields.join(',')
    end

    WebMock.disable_net_connect!
  end
end