class Array

  # @return The array with only the duplicated elements
  # @example
  #   [1,1,2,3,3,4,5,5,5,6].duplicates! # => [1,3,5]
  def duplicates!
    select! { |element| self.count(element) > 1 }.uniq!
    self
  end

  # Like duplicates! but does not change the receiver
  def duplicates
    clone.duplicates!
  end

end
