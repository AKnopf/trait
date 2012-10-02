module Traits
  HOME ||= [Traits]
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
      alias :incorporates_traits :trait
    end

  end
end

