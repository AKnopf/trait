class Hash

  # Transforms the hash into a Trait::Incorporation
  # @precondition Has the keys :traits, :resolves, :class_level_resolves and :incorporator
  def to_trait_incorporation
    Traits::Incorporation.new(self[:traits],
                              self[:resolves],
                              self[:class_level_resolves],
                              self[:incorporator])
  end

end
