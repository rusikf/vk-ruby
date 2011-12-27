# encoding: utf-8

class String
  if RUBY_VERSION >= '1.9'
    
    def valid_utf8?
      dup.force_encoding('UTF-8').valid_encoding?
    end

  else

    def valid_utf8?
      scan(Regexp.new('[^\x00-\xa0]', nil, 'u')) { |s| s.unpack('U') }
      true
    rescue ArgumentError
      false
    end
    
  end
end