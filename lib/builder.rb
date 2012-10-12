module Traits
  # The builder class implements the builder pattern for incorporations. It defines a nice and clean syntax for
  # incorporating traits into classes or traits
  class Builder

    private
    # @return [Array<Symbol>] Internal tracker of what methods where called to prevent
    #   calls in wrong order or inconsistent state
    attr_accessor :call_stack
    # @return [Hash<Trait,Hash>] The traits that will be part of the incorporation and its respective options
    attr_accessor :traits_accu
    # @return [Traitable] The class or trait that is the incorporator (needs to include Traitable)
    attr_accessor :incorporator
    # @return [Hash<Symbol,Proc>] The resolves (Proc) for conflicting methods (Symbol)
    attr_accessor :resolves_accu


    def initialize(incorporator)
      @call_stack    ||= [:list_traits]
      @incorporator  ||= incorporator
      @traits_accu   ||= { }
      @resolves_accu ||= { }
    end

    public

    def trait(trait)
      if call_stack.last == :trait
        call_stack.pop 2
        trait(trait)
      elsif call_stack.last == :list_traits
        trait = Trait[trait]
        call_stack << trait
        call_stack << :trait
        traits_accu[trait]= { }
        self
      else
        raise 'All traits must be added before defining resolves'
      end
    end

    def with_options(hash)
      if call_stack.last == :trait
        call_stack.pop
        traits_accu[call_stack.pop] = hash
        self
      else
        raise 'Options can only be defined for traits. Call "trait" before using "with_options"'
      end
    end

    def traits(*traits)
      traits.each { |trait| trait(trait) }
      self
    end

    def resolve(symbol)
      if call_stack.last == :list_traits
        call_stack.pop
        call_stack << :list_resolves
        resolve(symbol)
      elsif call_stack.last == :trait
        call_stack.pop 2
        resolve(symbol)
      elsif call_stack.last == :list_resolves
        call_stack << symbol
        call_stack << :resolve
        self
      else
        raise 'You may not call "resolve" here. Maybe you called "resolve" twice in a row? ' +
                  'You need to call "with_lambda" or "with_pattern" first.'
      end
    end

    alias_method :resolves, :resolve


    def with_lambda(proc)
      if call_stack.last == :resolve
        call_stack.pop
        resolves_accu[call_stack.pop] = proc
        self
      else
        raise 'You may not call "with_lambda" here. Call "resolve" first'
      end
    end

    def with_pattern
      if call_stack.last == :resolve
        call_stack << :pattern
        self
      else
        raise 'You may call "with_pattern" only after calling "resolve"'
      end
    end

    def call_in_order(order = traits_accu.keys)
      if call_stack.last == :pattern
        order = order.collect { |trait| Trait[trait] }
        call_stack.pop 2
        method_name                = call_stack.pop
        method_names               = order.collect { |trait| trait.aliased_method_name(method_name) }
        resolves_accu[method_name] = lambda do |*args, &block|
          method_names.each do
            self.send(method_name, *args, &block)
          end
        end
        self
      else
        raise 'You may call "call_in_order" only after "with_pattern"'
      end
    end

    def do_it
      build.incorporate
    end

    alias_method :done, :do_it
    alias_method :incorporate, :do_it


    def and
      self
    end


    def build
      Incorporation.new(traits_accu, resolves_accu, incorporator)
    end

    alias_method :incorporation, :build


  end
end
