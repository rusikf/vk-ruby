module VK

  # Files uploading.
  #
  # @param [Hash] params A list of files to upload (also includes the upload URL). See example for the hash format.
  #
  # @option params [String] :url URL for the request.
  #
  # @return [Hash] The server response.
  #
  # @raise [ArgumentError] raised when a `:url` parameter is omitted.
  #
  # @example
  #   VkontakteApi.upload(
  #     url:   'http://example.com/upload',
  #     file1: ['/path/to/file1.jpg', 'image/jpeg'],
  #     file2: ['/path/to/file2.png', 'image/png']
  #   )

  def self.upload(params = {})
    url = params.delete(:url)
    raise ArgumentError, 'You should pass :url parameter' unless url

    files = {}
    params.each do |param_name, (file_path, file_type)|
      files[param_name] = Faraday::UploadIO.new(file_path, file_type)
    end

    connection = Faraday.new do |faraday|
      faraday.request  :multipart
      faraday.request  :url_encoded
      faraday.response :json, content_type: /\bjson$/
      faraday.adapter  Faraday.default_adapter
    end

    connection.post(url, files)
  end
end