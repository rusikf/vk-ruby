require File.expand_path('../helpers', __FILE__)

class VkVariablesTest < MiniTest::Unit::TestCase

  def setup
    @var = VK::Executable::Variables.new
  end

  def test_attributes
    attributes = random_params

    attributes.each do|attribute_name,value| 
      @var.send("#{attribute_name}=", value)
    end

    attributes.each do|attribute_name,value| 
      assert_equal @var.send(attribute_name), attributes[attribute_name]
    end    
  end

  def test_to_hash
    attributes = random_params

    attributes.each do|attribute_name,value|
      @var.send("#{attribute_name}=", value)
    end

    assert_equal @var.to_hash.stringify, attributes
  end
  
end