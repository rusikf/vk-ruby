require File.expand_path('../helpers', __FILE__)

class Application
  extend VK::Configurable

  A = 'a'
  C = 'c'

  attr_configurable :a, :b
  attr_configurable :c, :d,  default: :default_value

  def initialize(params={})
    params.each{|key, value| send("#{key}=", value) }
  end
end

class TestConfigurable < MiniTest::Unit::TestCase

  def setup
    @application = Application.new(a: 1, d: 2)
  end

  def test_a
    assert_equal 1, @application.a
  end

  def test_b
    assert_equal nil, @application.b
  end

  def test_c
    assert_equal :default_value, @application.c
  end

  def test_d
    assert_equal 2, @application.d
  end

end