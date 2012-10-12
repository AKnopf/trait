module Traits
  module Traitable
    def self.included(base)
      # Makes the methods within ClassMethods class methods
      base.extend ClassMethods
    end

    module ClassMethods

      # @param [Hash|Incorporation] incorporation A hash that describes an incorporation of traits.
      # @see Incorporation#initialize
      def trait(incorporation)
        Incorporation[incorporation].incorporate
      end
      alias :traits :trait
      alias :has_traits :trait
      alias :incorporates :trait


      # Incorporates traits with the builder syntax
      # @see Traits::Builder
      def incorporate
        Builder.new(self)
      end
      alias :incorporates :incorporate
    end

  end
end

