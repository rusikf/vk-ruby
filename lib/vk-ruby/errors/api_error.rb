class VK::APIError < VK::Error
  def method
    @method ||= @env.url.path.split('/').last
  end

  def code
    @code ||= @env.body['error']['error_code'].to_i
  end

  def description
    @description ||= @env.body['error']['error_msg']
  end

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