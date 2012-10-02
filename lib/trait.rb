  module Traits
    # A +Trait+ abstracts from a module as a trait. It is immutable and state less.
    # Tasks are:
    # * Validation
    # * Finding trait modules
    # * convenient accessors to components of modules
    class Trait

      attr_reader :module

      def initialize(trait_name_or_module)
        if trait_name_or_module.is_a? Module
          @module = trait_name_or_module
        else
          @module = find_trait_module trait_name_or_module
        end

      end

      # @param [Trait|Hash] arg
      def self.[](arg)
        if arg.is_a? Trait
          arg
        else
          Trait.new arg
        end

      end

      def to_s
        "Trait[#{self.module}]"
      end

      def eql?(other)
        self.module.eql? other.module
      end

      def hash
        self.module.hash
      end

      def <=>(other)
        self.module <=> other.module
      end

      include Comparable

      def instance_methods
        self.module.instance_methods false
      end

      def simple_name
        self.module.to_s[/\w+\z/]
      end

      # Aliases all methods in +method_names+ with a suffix that is dependent on trait name
      # @example
      #   # In trait SimpleTrait
      #   # method :simple_method becomes :simple_method_in_simple_trait
      #   #
      def alias_methods(*method_names)
        trait = self
        self.module.module_eval do
          existing_instance_methods = method_names & trait.instance_methods
          existing_instance_methods.each do |method_name|
            alias_method trait.aliased_method_name(method_name), method_name
          end
        end
      end

      def aliased_method_name(method_name)
        last_letter = method_name.to_s[method_name.to_s.size-1]
        if %w(? !).member? last_letter
          # remove ? and ! from the middle and put it to the end
          (method_name.to_s.chop!+"_in_#{self.simple_name.to_snake_case}#{last_letter}").to_sym
        else
          (method_name.to_s+"_in_#{self.simple_name.to_snake_case}").to_sym
        end
      end

      private

      # @param [String|Symbol] name
      # @return [Module] The module with name, if it is in ::Chingu::Traits::HOME
      # @raise [RuntimeError] If trait was not found
      def find_trait_module(name)
        constant = name.to_constant
        ::Traits::HOME.each do |home|
          if home.const_defined? constant
            return home.const_get constant
          end
        end
        raise "trait '#{name}' was resolved to '#{constant}' but was not found."
      end
    end
  end
