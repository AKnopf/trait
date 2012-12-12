module Traits
  # The builder class implements the builder pattern for incorporations. It defines a nice and clean syntax for
  # incorporating traits into classes or traits
  # @example
  #   class Monster
  #     incorporate.
  #       traits(:movable,hittable,:emotion).
  #     resolve(:update,:draw).
  #       with_pattern.call_in_order.
  #     resolve(:moved?).
  #       manually{raise "Not clear what to do, think and re-implement"}.
  #     done
  #   end
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

    # Defines that a trait shall be incorporated.
    # @param [#to_trait] trait An object that can be converted to a #Trait.
    #   In the default implementation these are:
    #   * #Symbol
    #   * #Module
    #   * #Trait
    # @precondition {#trait} was called
    # @precondition {#traits} was called
    # @precondition {#with_options} was called
    # @precondition nothing was called
    # @postcondition {#trait} may be called
    # @postcondition {#traits} may be called
    # @postcondition {#with_options} may be called
    # @postcondition {#resolve} may be called
    # @postcondition {#done} may be called
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

    # Defines options under which a trait is incorporated into a class
    # @param [Hash<Symbol,Array<Symbol>>] hash A hash with the options.
    #
    #   Valid keys are +:except+ and +:only+.
    #
    #   The value is an Array of method names that will be treated like this:
    # [+:except+] excluded from the incorporation
    # [+:only+] exclusively included into the incorporation
    #
    # @precondition {#trait} was called
    # @precondition {#traits} was called
    # @postcondition {#trait} may be called
    # @postcondition {#traits} may be called
    # @postcondition {#resolve} may be called
    # @postcondition {#done} may be called
    # @example
    #   builder.trait(:moving).with_options({except: [:moved?,:draw]}).done
    #
    #   builder.trait(:moving).with_options({only: [:move_relative,:move_absolute]}).done
    def with_options(hash)
      if call_stack.last == :trait
        call_stack.pop
        traits_accu[call_stack.pop] = hash
        self
      else
        raise 'Options can only be defined for traits. Call "trait" before using "with_options"'
      end
    end

    # Defines that some methods of the latest defined trait are not incorporated.
    # @param [Array<Symbol>] methods Variable amount of method names to be excluded from
    #   the incorporation
    # @see #with_options
    # @note This method is just a shortcut for +with_options(:except => methods)+. It leads to
    #   more readable code
    def except(*methods)
      with_options(except: methods)
    end

    # Defines that some methods of the latest defined trait are exclusively incorporated.
    # @param [Array<Symbol>] methods Variable amount of method names to be exclusively included
    #   into the incorporation
    # @see #with_options
    # @note This method is just a shortcut for +with_options(:only => methods)+. It leads to
    #   more readable code
    def only(*methods)
      with_options(only: methods)
    end

    alias_method :but_only, :only

    # Defines that multiple traits me be called.
    # @param traits [Array<#to_trait>] An array with objects that can be converted into a trait.
    # @note For more information about #to_trait objects as well as pre and post conditions,
    #   see: {#trait}
    def traits(*traits)
      traits.each { |trait| trait(trait) }
      self
    end

    # @overload resolve(symbol)
    #   Defines the behavior of the resolved implementation of the method
    #   with the name in +symbol+
    #   @param [Symbol] symbol The name of the method to be resolved
    #   @precondition At least one trait is defined. {#trait} or {#traits} was called
    #   @postcondition A concrete resolve must be defined after this method. {#with_lambda}
    #     or {#with_pattern} must be called.
    #   @example
    #     builder.resolve(:update).with_pattern.<more methods>
    def resolve(*symbol)
      #--
      # The following overload of this method is half hearty implemented but not really ready for use
      # Thus it is not visible to in the documentation
      # @overload resolve(*symbols)
      #   Defines the behavior if the resolved implementation of multiple methods
      #   with the names in +symbols+
      #   @param [Array<Symbol>] symbols Varargs with the names of the methods to be resolved
      #   @precondition At least one trait is defined. {#trait} or {#traits} was called
      #   @postcondition A concrete resolve must be defined after this method. {#with_lambda}
      #     or {#with_pattern} must be called.
      #   @example
      #     builder.resolve(:update).with_pattern.<more methods>
      #--
      if symbol.length > 1
        symbol.each { |symbol| resolve(symbol) }
      else
        symbol = symbol[0]
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
    end

    alias_method :resolves, :resolve


    # Defines a concrete implementation that is used to resolve a method
    # @param [Proc] proc The implementation can be defined as a Proc object as only parameter
    # @yield [*args] The implementation can also be defined as a block to this method. If the
    #   parameter +proc+ is set, it takes precedence.
    # @precondition {#resolve} was called
    # @postcondition {#resolve} or {#done} can be called
    # @example
    #   builder.<some methods>.
    #     resolve(:my_method).
    #       with_lambda {my_method_in_trait_one + my_method_in_trait_two}. #using a block
    #     <further methods>.
    #   done
    # @example
    #   builder.<some methods>.
    #     resolve(:my_method).
    #       with_lambda(-> {my_method_in_trait_one + my_method_in_trait_two}). #using a Proc object
    #     <further methods>.
    #   done
    def with_lambda(proc = nil, &block)
      if call_stack.last == :resolve
        call_stack.pop
        proc                          ||= block
        resolves_accu[call_stack.pop] = proc
        self
      else
        raise 'You may not call "with_lambda" here. Call "resolve" first'
      end
    end

    alias_method :manually, :with_lambda

    # Defines a concrete implementation that is used to resolve a method in form of a pattern
    # @precondition {#resolve} was called
    # @postcondition One of the pattern methods is called. In this moment these are:
    #   * {#call_in_order}
    def with_pattern
      if call_stack.last == :resolve
        call_stack << :pattern
        self
      else
        raise 'You may call "with_pattern" only after calling "resolve"'
      end
    end

    # Defines a concrete implementation to resolve a method in the form that all versions of
    # the method are called in an order
    # @param [Array<Symbol>] order The order in which the different versions are called.
    #   The default value is the order in which the traits were defined
    # @precondition {#with_pattern} was called
    # @postcondition {#resolve} or {#done} are called
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

    # Triggers the actual incorporation of traits
    # @precondition Traits defined
    # @precondition All conflicts resolved
    # @raise [RuntimeError] When there are unsolved conflicts
    def do_it
      build.incorporate
    end

    alias_method :done, :do_it
    alias_method :incorporate, :do_it


    # Syntactic sugar
    def and
      self
    end

    # Returns the incorporation object without applying it to the incorporator.
    # @note Do not use this unless you know what you do. If you just want to use traits, use the
    #   {#done} method instead.
    def build
      Incorporation.new(traits_accu, resolves_accu, incorporator)
    end

    alias_method :incorporation, :build


  end
end
