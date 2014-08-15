# Authentification error implementation

class VK::AuthentificationError < VK::Error
  
  # @!attribute [r] error
  #   @return [String] error
  #
  # @!attribute [r] description
  #   @return [String] error description

  attr_accessor :error, :description

  alias error_description description

  def initialize(params)
    params.each { |k,v| send("#{ k }=", v) if respond_to?("#{ k }=") }
  end

  def to_s
    [error, description].join(': ')
  end

end