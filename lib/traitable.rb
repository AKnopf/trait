module Traits
  HOME ||= [Traits]
  module Traitable
    def self.included(base)
      # Define class instance variable trait_options for including class
      class << base
        attr_accessor :trait_options
      end
      base.trait_options ||= { }
      # Makes the methods within ClassMethods class methods
      base.extend ClassMethods
    end

    module ClassMethods

      # @param [Hash|Incorporation] options A hash that describes an incorporation of traits.
      # @see Incorporation#initialize
      def trait(options)
        trait = Trait.new(module:       name,
                          incorporator: self)
        trait.incorporate
        # module found and not already included
        #if mod && !ancestors.member?(mod)
        #  # trait dependencies of trait
        #  dependencies = mod.const_fetch :Dependencies
        #  if dependencies
        #    dependencies.each do |dependency, options|
        #      trait dependency, options
        #    end
        #  end
        #  # create new mod for attribute-setting
        #  attributes_mod = to_attributes_mod mod, options
        #  # include trait instance methods
        #  include mod
        #  # include setup_trait with attributes
        #  include attributes_mod if attributes_mod
        #  # handle class methods
        #  class_mod = mod.const_get :ClassMethods if mod.const_defined? :ClassMethods
        #  if class_mod
        #    extend class_mod
        #    # call initialize trait if defined
        #    send :initialize_trait, options if respond_to? :initialize_trait
        #  end
        #end
      end

      alias :has_trait :trait


      # @param [VarArg<Symbol|String>] trait_names Names of traits that are incorporated
      def traits(*trait_names)
        trait_names.each { |trait_name| trait(trait_name) }
      end

      alias :has_traits :traits

    end

  end
end

