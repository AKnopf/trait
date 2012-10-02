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

    # @return [Hash<Symbol, Resolve>] resolves names of possibly conflicting methods and their respective
    #   resolve patterns
    attr_reader :resolves

    # @return [Traitable] The class or trait module that uses this incorporation of traits
    attr_reader :incorporator


    def self.[](*args)
      if args.is_a?(Array) && args.size > 1
        new(*args)
      elsif args[0].respond_to? :to_trait_incorporation
        args[0].to_trait_incorporation
      end
    end

    def to_trait_incorporation
      self
    end


    def initialize(traits,
        resolves,
        incorporator)

      @traits       = initialize_traits normalize_traits traits
      @resolves     = initialize_resolves normalize_resolves resolves
      @incorporator = incorporator

      validate

    end


    # Executes the Incorporation of traits into a trait or class.
    def incorporate
      if colliding_methods.empty? #trivial case: no conflicts
        traits.keys.each { |trait| incorporator.send(:include, trait.module) }
      elsif unresolved_colliding_methods.empty? # all conflicts are resolved
        traits.keys.each { |trait| trait.alias_methods(*colliding_methods) }
        traits.keys.each { |trait| incorporator.send(:include, trait.module) }
        incorporation_resolves = self.resolves
        colliding_methods.each do |method|
          incorporator.send(:define_method, method, incorporation_resolves[method].lambda)
        end
      else # unresolved conflicts
        raise "there are unresolved colliding methods: #{unresolved_colliding_methods}"
      end
    end


    def colliding_methods
      # Get methods from traits
      methods = traits.keys.collect(&:instance_methods)
      # Get methods from incorporator
      methods << incorporator.instance_methods(false)
      # Flatten them to one array
      methods = methods.flatten!
      # Select those that are duplicated and return an array with one of each
      methods.duplicates!
    end

    def unresolved_colliding_methods
      colliding_methods - resolves.keys
    end

    private


    def validate
      validate_traits
      validate_resolves resolves
      validate_incorporator
    end

    def validate_incorporator
      raise "The incorporator #{incorporator} must include the Traitable module" unless incorporator.include?(Traitable)
    end

    # Makes Resolves default to an empty hash. Also splits up an array key into its elements as keys.
    # {[:a,:b] => {}} becomes {:a => {}, :b => {}}
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

    # Makes a Hash<Symbol,Resolve> out of Hash<Symbol, Resolve|Hash>
    def initialize_resolves(normalized_resolves)
      default_order       = traits.keys
      default_options     = { order:     default_order,
                              link_mode: :call_in_order }
      normalized_resolves = normalized_resolves.collect do |method_name, resolve_options|
        actual_resolve_options = default_options.merge(resolve_options)
        { method_name => Resolve[actual_resolve_options] }
      end
      normalized_resolves.inject({ }, :merge)
    end

    # Makes attributes default to an empty hash
    def normalize_attributes(attributes)
      attributes || { }
    end

    # Makes an Hash<Trait,Hash> out of a Hash<Symbol|Module, Hash> (name or module with their respective options)
    def initialize_traits(normalized_traits)
      normalized_traits.collect { |trait_name, options| { Trait[trait_name] => options } }.inject(&:merge)
    end

    # Makes Array<Symbol|Module> or a Symbol to a hash with all empty hashes as key. So if traits are specified as
    # array, they are converted into their notation with incorporation options
    def normalize_traits(traits)
      if traits.is_a? Array
        validate_traits_as_array traits
        traits.collect { |trait| { trait => { } } }.inject(&:merge)
      elsif traits.is_a?(Symbol) || traits.is_a?(Module)
        { traits => { } }
      else
        traits
      end
    end

    def validate_traits
      valid = traits.all? { |trait, options| trait.instance_of?(Trait) && options.instance_of?(Hash) }
      raise "Traits must be instance of ::Traits::Trait" unless valid
    end

    def validate_traits_as_array(traits)
      #raise "Traits must be specified as Array<Symbol|Module>" unless
      traits.respond_to? :all and traits.all? { |trait|
        trait.is_a?(Symbol) || trait.is_a?(Module) }
    end

    def validate_traits_normalized(traits)
      raise "Traits must be specified as Hash<Symbol,Object>" unless traits.respond_to? :all and
          traits.all? { |trait_name, options| trait_name.is_a?(Symbol) || trait_name.is_a?(Module) &&
              options.is_a?(Hash) }
    end

    def validate_resolves(resolves)
      raise "Resolves must be specified as a Hash or list of resolves" unless resolves.is_a?(Hash) ||
          resolves.all? { |resolve| resolve.is_a?(Resolve) && resolve.validate }
    end

  end
end
