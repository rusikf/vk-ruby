# encoding: UTF-8

module VK
  class ApiException < Exception
    attr_reader :vk_method, :error_code, :error_msg

    def initialize api_method, error_hash
      @vk_method = api_method
      @error_code = error_hash['error']['error_code'].to_i
      @error_msg = "Error #{@error_code} in `#{@vk_method}' - #{error_hash['error']['error_msg']}"
      super @error_msg
    end
  end

  class AuthorizeException < Exception
    attr_reader :error, :error_msg

    def initialize error_hash
      @error = error_hash['error']
      @error_msg = "Error #{@error} - #{error_hash['error_description']}"
      super @error_msg
    end
  end

  class ParseException < Exception
    def initialize string
      @error_msg = "Bad string\n" + string
      super @error_msg
    end
  end
end