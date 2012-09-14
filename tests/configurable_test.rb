require File.expand_path('../helpers', __FILE__)

module Test
  A = 'A'
  B = 'B'
  D = 'D'

  class Application
    extend VK::Configurable

    C = 'C'

    attr_configurable :a, :b
    attr_configurable :c, :d,  default: :default_value

    def initialize(params={})
      params.each{|key, value| send("#{key}=", value) }
    end
  end
end

class TestConfigurable < MiniTest::Unit::TestCase

  def setup
    @application = Test::Application.new(a: 1, d: 2)
  end

  def test_a
    assert_equal @application.a, 1
    @application.a = :new_value
    assert_equal @application.a, :new_value
  end

  def test_b
    assert_equal @application.b, 'B'
    @application.b = :new_value
    assert_equal @application.b, :new_value
  end

  def test_c
    assert_equal @application.c, :default_value
    @application.c = :new_value
    assert_equal @application.c, :new_value
  end

  def test_d
    assert_equal @application.d, 2
    @application.d = :new_value
    assert_equal @application.d, :new_value
  end

end