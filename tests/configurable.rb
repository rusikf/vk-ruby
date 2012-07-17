require File.expand_path('../helpers', __FILE__)

class TestConfigurable < MiniTest::Unit::TestCase

  def setup
    @application = Object.new
    @application.include Vk::Configurable
    @application.class_eval do 
      at
    end
  end

  def test_that_kitty_can_eat
    assert_equal "OHAI!", @meme.i_can_has_cheezburger?
  end

  def test_that_it_will_not_blend
    refute_match %r/^no/, @meme.will_it_blend?
  end

end