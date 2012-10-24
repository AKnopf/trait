  module Traits
    # A +Trait+ abstracts from a module as a trait. It is immutable and state less.
    # Tasks are:
    # * Validation
    # * Finding trait modules
    # * convenient accessors to components of modules
    class Trait

      attr_reader :module

      def initialize(_module)
          @module = _module
      end

      # @param [Trait|Hash] arg
      def self.[](arg)
        arg.to_trait
      end

      # @return self
      def to_trait
        self
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

      # Returns the instance methods that are defined in this trait, methods can be restricted via options
      # @param [Hash<(:only|:except),Array<Symbol>] options May include key :only or :except to restrict the methods
      #   that are returned
      # @return [Array<Symbol>] An array with method names of instance methods that are defined in this trait after
      #   filtering them with :only or :except
      # @raise RuntimeError if method names in :only or :except are not defined in this trait
      def instance_methods(options = {})
        if options.empty?
          self.module.instance_methods false
        elsif options[:except]
          ensure_all_methods_existent(self,options[:except],'except')
          instance_methods - options[:except]
        elsif options[:only]
          ensure_all_methods_existent(self,options[:only],'only')
          options[:only]
        end
      end


      # Returns the name of the module without its nesting
      # @example
      #   Trait[MyApp::MyTraits::MyAwesomeTrait].simple_name #=> "MyAwesomeTrait"
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


      private

      def ensure_all_methods_existent(trait, sub_set_of_methods, except_or_only)
        too_many = sub_set_of_methods - trait.instance_methods
        unless too_many.empty?
          raise "Error in #{except_or_only} clause: #{too_many} methods are not defined in the trait #{trait}"
        end
      end
    end
  end
