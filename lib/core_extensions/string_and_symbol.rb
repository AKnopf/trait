module CanBeTrait
  def to_trait
    constant = to_constant
    ::Traits::HOME.each do |home|
      if home.const_defined? constant
        return Traits::Trait[home.const_get constant]
      end
    end
    raise "trait '#{name}' was resolved to '#{constant}' but was not found."
  end
end

module CanBeConstant

  # :movable_object | :movableObject | "movable object" | :movableObject => :MovableObject
  def to_constant
    next_is_capital = false
    first_letter    = true
    result          = ""
    to_s.each_char do |char|
      if first_letter
        result << char.upcase
        first_letter = false
      else
        if char =~ /[\s_]/
          next_is_capital = true
        else
          if next_is_capital
            result << char.upcase
            next_is_capital = false
          else
            result << char
          end
        end
      end
    end
    result.to_sym
  end

  # :movable_object | :movableObject | "movable object" | :movableObject => 'movable_object'
  def to_snake_case
    # code reused from http://rubydoc.info/gems/extlib/0.9.15/String#snake_case-instance_method
    constant_string = to_constant.to_s
    return constant_string.downcase if constant_string.match(/\A[A-Z]+\z/)
    constant_string.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
        gsub(/([a-z])([A-Z])/, '\1_\2').
        downcase
  end
end


class String
  include CanBeTrait
  include CanBeConstant
end

class Symbol
  include CanBeTrait
  include CanBeConstant
end
