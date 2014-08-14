class VK::AuthentificationError < VK::Error

  attr_accessor :error, :description

  alias error_description description

  def initialize(params)
    params.each { |k,v| send("#{ k }=", v) if respond_to?("#{ k }=") }
  end

  def to_s
    [error, description].join(': ')
  end

end