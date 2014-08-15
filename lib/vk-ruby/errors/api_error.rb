# API error implementation

class VK::APIError < VK::Error
  # @!attribute [r] method
  #   @return [String] API method
  def method
    @method ||= @env.url.path.split('/').last
  end

  # @!attribute [r] code
  #   @return [String] API error code
  def code
    @code ||= @env.body['error']['error_code'].to_i
  end

  # @!attribute [r] description
  #   @return [String] API error description
  def description
    @description ||= @env.body['error']['error_msg']
  end

  # @!attribute [r] request_params
  #   @return [String] request params
  def request_params
    @request_params ||= @env.body['error']['request_params'].inject({}) do |a, hash|
      a[hash['key']] = hash['value']
      a
    end
  end

  alias params request_params

  def to_s
    "code=#{ code } method='#{method}' description='#{ description }'"
  end
end