  module Traits
    # A resolve is the process of resolving a name conflict among methods that occurred due to the incorporation of
    # multiple traits.
    #
    # *Example*:
    #
    # A class Bullet incorporates two traits Movable and CollisionDetection both of which implement the method
    # +update+. The Bullet class class itself implements the update method, also. Now there are three implementations
    # of the method +update+. Which of those needs to be called when +update+ is sent to the instance? Maybe even a
    # combination of all three? And in which order? Those questions are answered by a Resolve
    #
    class Resolve

      # @return [Array<Trait>]
      # The order in which different implementations will be linked.
      attr_reader :order

      # @return [:inject, :collect, :call_in_order] link_mode
      attr_reader :link_mode

      # @return [Symbol]
      # If the link_mode is +:inject+, the link_operator is used to link the implementations' results
      attr_reader :link_operator

      # @return [Proc]
      # If the conflict cannot be solved by inject, collect or call_in_order, a custom code in form a
      # lambda needs to be called instead. Within the lambda the old versions of the implementation are accessible via
      # aliased methods.
      # @example
      #   -> { update_bullet; update_movable; update_collision_detection }
      #   # This would be equivalent to call_in_order
      attr_reader :lambda


      # @param [Array<Symbol|Module|Trait>] order
      #   The order in which different implementations will be linked. A
      #   Symbol is the name of the trait (e.g. +:movable+), a module is its module (e.g +::Chingu::Traits::Movable+)
      #   or the Trait instance itself.
      # @param [:inject, :collect, :call_in_order] link_mode
      # @param [Symbol] link_operator
      #   If the link_mode is +:inject+, the link_operator is used to link the implementations' results
      # @param [Proc] lambda
      #   @see Resolve#lambda
      def initialize(order, link_mode, link_operator, lambda = nil)

        @order = normalize_order order if order
        @link_mode     = link_mode || :call_in_order
        @link_operator = link_operator
        @lambda        = lambda

        validate
      end

      def self.manually
        self[lambda: -> { yield }]
      end

      def self.[](*args)
        if args[0].is_a?(Hash)
          hash = args[0]
          if hash[:lambda] # Hash with lambda
            new hash[:order], nil, nil, hash[:lambda]
          else # Hash with link mode
            new hash[:order], hash[:link_mode], hash[:link_operator]
          end
        elsif args[0].is_a? Resolve
          args[0]
        else # Plain arguments
          new *args
        end
      end

      private

      def validate
        lambda.nil? ? validate_with_pattern : validate_with_lambda
      end

      def validate_with_pattern
        raise "There must either be a lambda or a resolve pattern defined" unless lambda.nil?
        raise "Order must be an Array<Trait> but is #{order.inspect}" unless order.respond_to?(:all?) and order
        .all? {
            |trait|
          trait.instance_of?(Trait) }
        raise "link_mode must be one of [:inject, :collect, :call_in_order]" unless [:inject, :collect,
                                                                                     :call_in_order].member?(link_mode)
        raise "link_operator must be a symbol" unless link_mode == :call_in_order or link_operator.is_a?(Symbol)
      end

      def validate_with_lambda
        raise "Lambda must respond to call" unless lambda.respond_to?(:call)
      end


      def normalize_order(order)
        order.collect { |trait| Trait[trait] }
      end

    end
  end
