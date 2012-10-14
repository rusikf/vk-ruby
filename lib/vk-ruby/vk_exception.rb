# encoding: UTF-8

module VK

  class Error < StandardError
  end

  class ApiException < Error

    attr_reader :vk_method, :code, :discription

    def initialize(api_method, error_hash)
      @vk_method = api_method
      @code = error_hash['error']['error_code'].to_i
      @discription = error_hash['error']['error_msg']
    end

    def to_s
      "Error #@code in #@vk_method : #@discription"
    end
  end

  class AuthorizeException < Error

    attr_reader :error, :description

    def initialize(error_hash)
      @error = error_hash['error']
      @description = error_hash['error_description']
    end

    def to_s
      "Error #@error : #@description"
    end
  end

  class BadResponseException < Error

    attr_reader :response

    def initialize(response)
      @response = response
      super
    end

    def to_s
      "Bad response (#{ response.status })"
    end

  end

end