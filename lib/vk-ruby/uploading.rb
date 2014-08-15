# File uploading implementation

module VK::Uploading

  # Files uploading
  #
  # @param url [String] URL for the request
  # @param files [Array|Hash] list of files. See example for the list format
  #
  # @return [Hash] The server response
  #
  # @example Upload with hash list
  #   application.upload(
  #     'http://example.vk.com/path',{
  #       file1: ['/path/to/file1.jpg', 'image/jpeg'],
  #       file2: [io, 'image/png', '/path/to/file2.png'] 
  #   })
  #
  # @example Upload with array list
  #   application.upload(
  #     'http://example.vk.com/path',[
  #       ['/path/to/file1.jpg', 'image/jpeg'],
  #       [io, 'image/png', '/path/to/file2.png']
  #   ])
  #
  # @raise [VK::APIError] with API error

  def upload(url, files)
    params = {}

    if files.is_a? Array
      files.each_with_index do |(file_path_or_io, file_type, file_path), index|
        params[[:file, index.next].join.to_sym] = Faraday::UploadIO.new(file_path_or_io, file_type, file_path)
      end
    else
      params = files.inject({}) do |acc, (name, (file_path_or_io, file_type, file_path))|
        acc[name] = Faraday::UploadIO.new(file_path_or_io, file_type, file_path)
        acc
      end
    end
    
    request(params) { |req| req.url(url) }.body
  end
end
