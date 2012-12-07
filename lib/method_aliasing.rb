module MethodAliasing

  # Returns the name of the module without its nesting
  # @example
  #   Trait[MyApp::MyTraits::MyAwesomeTrait].simple_name #=> "MyAwesomeTrait"
  def simple_name
    module_or_self.to_s[/\w+\z/]
  end

  # Aliases all methods in +method_names+ with a suffix that is dependent on trait name
  # @example
  #   In trait SimpleTrait
  #   method :simple_method becomes :simple_method_in_simple_trait
  def alias_methods(*method_names)
    trait   = self
    module_or_self.module_eval do
      existing_instance_methods = method_names & trait.instance_methods
      existing_instance_methods.each do |method_name|
        alias_method trait.aliased_method_name(method_name), method_name
      end
    end
  end

  def module_or_self
    respond_to?(:module) ? self.module : self
  end

  # Returns the name of a method with the suffix of this trait.
  # @example
  #   Trait[MyTrait].aliased_method_name(:my_method) => :my_method_in_my_trait
  def aliased_method_name(method_name)
    last_letter = method_name.to_s[method_name.to_s.size-1]
    if %w(? !).member? last_letter
      # remove ? and ! from the middle and put it to the end
      (method_name.to_s.chop!+"_in_#{self.simple_name.to_snake_case}#{last_letter}").to_sym
    else
      (method_name.to_s+"_in_#{self.simple_name.to_snake_case}").to_sym
    end
  end

end
