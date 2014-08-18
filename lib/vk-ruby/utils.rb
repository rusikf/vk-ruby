# Internal helpers

module VK::Utils

  # Get real API method name
  # 
  # @example Camelize API method
  #   VK::Utils.camelize('get_profiles') #=> 'getProfiles'

  def self.camelize(name)
    words = name.to_s.split('_')
    first_word = words.shift
    words.each{ |word| word.sub! /^[a-z]/, &:upcase }
    words.unshift(first_word).join
  end

  def self.deep_merge(a, b)
    b.each_pair do |k,bv|
      av = a[k]

      if av.is_a?(Hash) && bv.is_a?(Hash)
        a[k] = deep_merge(av, bv)
      else
        a[k] = bv
      end
    end

    a
  end

  def self.stringify(object)
    case object
    when Hash
      object.inject({}) { |acc, (k,v)| acc[k.to_s] = stringify(v); acc }
    when Array
      object.map { |v| stringify v }
    when Fixnum, TrueClass, FalseClass, NilClass
      object
    else
      object.to_s
    end
  end

  def self.symbolize(object)
    case object
    when Hash
      object.inject({}) do |acc, (k,v)|
        acc[k.to_sym] = v.is_a?(String) ? v : symbolize(v)
        acc
      end
    when Array
      object.map {|v| symbolize v }
    when Fixnum, TrueClass, FalseClass, NilClass
      object
    else
      object.to_sym
    end
  end

  def self.compact(object)
    case object
    when Hash
      object.inject({}) do |acc,(k,v)|
        compact_value = compact(v)
        acc[k] = compact_value unless compact_value.nil? || (compact_value.respond_to?(:empty?) && compact_value.empty?)
        acc
      end
    when Array
      object.compact
    else
      object
    end
  end
  
end