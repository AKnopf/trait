require_relative '../lib/core_extensions/array'
require_relative '../lib/core_extensions/can_be_constant'
require_relative '../lib/core_extensions/hash'
require_relative '../lib/core_extensions/module'

require_relative '../lib/incorporation'
require_relative '../lib/resolve'
require_relative '../lib/trait'
require_relative '../lib/traitable'

require 'singleton'

#noinspection ALL
module Traits

  describe Traitable do

    describe 'basic behavior' do
      module BasicBehavior
        class GameObject
          include Traitable
        end
      end

      it 'should respond to method "trait" and its aliases' do
        BasicBehavior::GameObject.should respond_to(:trait,
                                                    :traits,
                                                    :has_traits,
                                                    :incorporates,
                                                    :incorporates_traits)
      end


      it 'should trigger the incorporation of a Traits::Incorporation' do
        # fake class that can check if incorporate has been called
        class MockIncorporation

          include Singleton
          attr_accessor :incorporated

          def self.[](*args)
            instance
          end

          def initialize
            self.incorporated = false
          end

          def incorporate
            self.incorporated = true
          end
        end

        # Switch original class with fake class
        ORIGINAL_INCORPORATION, Incorporation = Incorporation, MockIncorporation

        module Hittable
          # logic for hitting an object
        end

        module BasicBehavior
          class GameObject
            trait ({some_definition: "of a trait"})
          end
        end

        Incorporation.instance.incorporated.should be_true

        # Switch back to original class
        Incorporation = ORIGINAL_INCORPORATION
      end
    end
  end
end
