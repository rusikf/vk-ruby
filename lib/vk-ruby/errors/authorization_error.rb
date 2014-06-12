class VK::AuthorizationError < VK::Error
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