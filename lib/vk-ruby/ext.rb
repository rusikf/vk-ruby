class String
  def to_vkscript
    self
  end
end

class Integer
  def to_vkscript
    self.to_s
  end
end

class Float
  def to_vkscript
    self.to_s
  end
end

class Array
  def to_vkscript
    self.map{|i| i.to_vkscript}.join(',')
  end
end

class Hash
  def to_vkscript
    ['{', self.map{|k,v| "\"#{k}\":\"#{v.to_vkscript}\""}.join(','), '}'].join
  end
end

class Proc
  def bind(other)
    return Proc.new do
      other.instance_eval(&self)
    end
  end
end