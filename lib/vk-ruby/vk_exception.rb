# encoding: UTF-8

module VK
  class ApiException < Exception
    attr_reader :vk_method, :error_code, :error_msg

    def initialize api_method, error_hash
      @vk_method, @error_code = api_method, error_hash['error']['error_code'].to_i
      @error_msg = "Error #{@error_code} in `#{@vk_method}' - #{error_hash['error']['error_msg']}"
      super @error_msg
    end
  end

  class AuthorizeException < Exception
    attr_reader :error, :error_msg

    def initialize error_hash
      @error, @error_msg = error_hash['error'], "Error #{@error} - #{error_hash['error_description']}"
      super @error_msg
    end
  end

  class ParseException < Exception
    attr_reader :bad_string 

    def initialize string
      @bad_string, @error_msg = string, ("Bad string ...\n" + string[0..500] + "\n...")
      super @error_msg
    end
  end

  class BadResponseException < Exception
    attr_reader :response, :params

    def initialize response, verbs, path, options
      @response, @params = response, params
      @error_msg = "Bad response"
      super @error_msg
    end
  end
end