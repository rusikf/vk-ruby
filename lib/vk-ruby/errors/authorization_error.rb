# Authorization error implementation

class VK::AuthorizationError < VK::Error
  # @!attribute [r] error
  #   @return [String] error
  #
  # @!attribute [r] description
  #   @return [String] error description

  def error
    @error ||= @env.body['error']
  end

  def description
    @description ||= @env.body['error_description']
  end

  def to_s
    "error='#{ error }' description='#{ description }'"
  end
end