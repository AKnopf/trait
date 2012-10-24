module Traits
# An Incorporation is the process of incorporating traits into a class or a another trait.
# The following things must be specified to incorporate traits:
# * [The traits themselves]
#   This can be done in the form of an array of symbols (the name of the trait) or an array of modules (the
#   actual trait). A single trait with default options can be specified as a plain Symbol or Module
#   [The options for traits]
#     If using an array for specifying the traits, all options will be defaults. A Hash with the Symbol (name)
#     or module (actual trait) as key and its options can be used, to specify each traits' options. Options are
#     always in the form of Hash<Symbol,Object>. What the actual options are, depends on the trait.
# * [Resolves]
#   Traits not only add attributes to the class, but also methods. When multiple traits are incorporated, there
#   can occur name conflicts. These must be manually resolved. As there are common patterns to resolve these
#   conflict, this can be done compactly during the incorporation by defining these patterns.
  class Incorporation

    # @return [Hash<Trait, Hash>] traits that are incorporated from the incorporator and their respective options
    attr_reader :traits

    # @return [Hash<Symbol, Proc>] resolves names of possibly conflicting methods and their respective resolve als
    #   proc
    attr_reader :resolves

    # @return [Traitable] The class or trait module that uses this incorporation of traits
    attr_reader :incorporator


    # Creates a new Incorporation out of an argument list or anything that responds to :to_trait_incorporation
    def self.[](*args)
      if args.is_a?(Array) && args.size > 1
        new(*args)
      elsif args[0].respond_to? :to_trait_incorporation
        args[0].to_trait_incorporation
      end
    end

    # @return [self]
    def to_trait_incorporation
      self
    end


    # Initializes the Incorporation object with traits, resolves and incorporator
    def initialize(traits,
        resolves,
        incorporator)
      @traits       = initialize_traits normalize_options normalize_traits traits
      @resolves     = normalize_resolves resolves
      @incorporator = incorporator

      validate

    end

    def normalize_options(normalized_traits)
      normalized_traits.each do |_, options|
        [:only, :except].each do |option|
          options[option] = [options[option]] if options[option] and !options[option].is_a?(Array)
        end
      end
    end

    # Executes the Incorporation of traits into a trait or class.
    # @raise [RuntimeError] if there are unresolved colliding methods
    # @raise [RuntimeError] if there are methods in :only or :except clauses that are not defined in the respective
    #   trait
    def incorporate
      if colliding_methods.empty? #trivial case: no conflicts
        traits.each { |trait, options| incorporate_single_trait trait, options }
      elsif unresolved_colliding_methods.empty? # all conflicts are resolved
        traits.each do |trait, options|
          trait.alias_methods *colliding_methods
          incorporate_single_trait trait, options
        end
        incorporation_resolves = self.resolves
        colliding_methods.each do |method|
          incorporator.send(:define_method, method, incorporation_resolves[method])
        end
      else # unresolved conflicts
        raise "there are unresolved colliding methods: #{unresolved_colliding_methods}"
      end
    end

    # @return [Array<Symbol>] Method names of methods that are implemented by more than one trait or by the
    #   incorporator + at least one trait
    def colliding_methods
      # Get methods from traits
      methods = []
      traits.each do |trait, options|
        methods += trait.instance_methods(options)
      end
      # Get methods from incorporator
      methods << incorporator.instance_methods(false)
      # Flatten them to one array
      methods.flatten!
      # Select those that are duplicated and return an array with one of each
      methods.duplicates!
    end

    def ensure_all_methods_existent(trait, sub_set_of_methods, except_or_only)
      too_many = sub_set_of_methods - trait.instance_methods
      unless too_many.empty?
        raise "Error in #{except_or_only} clause: #{too_many} methods are not defined in the trait #{trait}"
      end
    end


    # @return [Array<Symbol>] Method names of methods that are colliding, but have no resolve
    def unresolved_colliding_methods
      colliding_methods - resolves.keys
    end

    private

    # Adds the methods from trait filtered by options to the incorporator
    def incorporate_single_trait(trait, options)
      incorporator.send(:include, trait.module)
      if options[:except]
        filter = ExceptFilter[incorporator, trait.module, *options[:except]]
        incorporator.send(:include, filter)
      elsif options[:only]
        filter = OnlyFilter[incorporator, trait.module, *options[:only]]
        incorporator.send(:include, filter)
      end
    end


    # Checks whether the normalization was successful
    # @raise [RuntimeError] if instance variables have unexpected format
    def validate
      validate_traits
      validate_resolves resolves
      validate_incorporator
    end


    # Makes Resolves default to an empty hash. Also splits up an array key into its elements as keys.
    # {[:a,:b] => ->{}} becomes {:a => ->{}, :b => ->{}}
    def normalize_resolves(resolves)
      resolves                  = resolves || { }
      resolves_with_array_match = resolves.select { |match, _| match.is_a?(Array) }
      resolves_with_array_match.each do |array, resolve|
        array.each do |match|
          resolves[match] = resolve
        end
      end
      resolves.reject! { |match, _| match.is_a?(Array) } || resolves
    end

    # Makes an Hash<Trait,Hash> out of a Hash<Symbol|Module, Hash> (name or module with their respective options)
    def initialize_traits(normalized_traits)
      normalized_traits.collect { |trait_name, options| { Trait[trait_name] => options } }.inject(&:merge)
    end

    # Makes Array<Symbol|Module> or a Symbol to a hash with all empty hashes as key. So if traits are specified as
    # array, they are converted into their notation with incorporation options
    def normalize_traits(traits)
      if traits.is_a? Array
        traits.collect { |trait| { trait => { } } }.inject(&:merge)
      elsif traits.is_a?(Symbol) || traits.is_a?(Module)
        { traits => { } }
      else
        traits
      end
    end

    # @raise [RuntimeError] if incorporator is not traitable
    def validate_incorporator
      raise "The incorporator #{incorporator} must include the Traitable module" unless incorporator.include?(Traitable)
    end

    # @raise [RuntimeError] if traits are not instances of Trait and options are instances of Hash
    def validate_traits
      valid = traits.all? { |trait, options| trait.instance_of?(Trait) && options.instance_of?(Hash) }
      raise "Traits must be instance of ::Traits::Trait" unless valid
    end

    def validate_traits_normalized(traits)
      raise "Traits must be specified as Hash<Symbol,Object>" unless traits.respond_to? :all and
          traits.all? { |trait_name, options| trait_name.is_a?(Symbol) || trait_name.is_a?(Module) &&
              options.is_a?(Hash) }
    end

    def validate_resolves(resolves)
      raise "Resolves must be specified as a Hash" unless resolves.is_a?(Hash) ||
          resolves.all? { |symbol, proc| symbol.is_a?(Symbol) and proc.is_a?(Proc) }
    end

  end
end
