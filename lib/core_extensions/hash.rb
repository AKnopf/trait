class Hash

  def to_trait_incorporation
    Traits::Incorporation.new(self[:traits],
                              self[:resolves],
                              self[:class_level_resolves],
                              self[:incorporator])
  end

end
