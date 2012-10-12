class Module

  # @param [Symbol] name Name of the constant to look up
  # @return [Object] The value behind the constant, if defined. The alt parameter,
  #   if given. The result of the block, if given. Nil else.
  # @param [Object] alt The default value if constant is not defined.
  def const_fetch(name, alt = nil)
    if const_defined? name
      const_get name
    elsif !alt.nil?
      alt
    elsif block_given?
      yield
    else
      nil
    end
  end

  def to_trait
    Traits::Trait.new(self)
  end

end
