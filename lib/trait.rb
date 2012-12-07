  module Traits
    # A +Trait+ abstracts from a module as a trait. It is immutable and state less.
    # Tasks are:
    # * Validation
    # * Finding trait modules
    # * convenient accessors to components of modules
    class Trait

      include MethodAliasing

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

      private

      def ensure_all_methods_existent(trait, sub_set_of_methods, except_or_only)
        too_many = sub_set_of_methods - trait.instance_methods
        unless too_many.empty?
          raise "Error in #{except_or_only} clause: #{too_many} methods are not defined in the trait #{trait}"
        end
      end
    end
  end
