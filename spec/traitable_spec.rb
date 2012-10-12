require_relative '../lib/core_extensions/array'
require_relative '../lib/core_extensions/hash'
require_relative '../lib/core_extensions/module'

require_relative '../lib/incorporation'
require_relative '../lib/trait'
require_relative '../lib/traitable'
require_relative '../lib/builder'

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
                                                    :incorporates)
      end

      it 'should respond to method "incorporate" and its aliases' do
        BasicBehavior::GameObject.should respond_to(:incorporate,
                                                    :incorporates)
      end

      it 'should create a Builder when calling "incorporate"' do
        builder = nil
        BasicBehavior::GameObject.class_eval do
          builder = self.incorporate
        end
        builder.should be_instance_of(Builder)
        builder.send(:incorporator).should == BasicBehavior::GameObject
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

        # Silently switch original class with fake class
        old_verbose, $VERBOSE                 = $VERBOSE, nil
        ORIGINAL_INCORPORATION, Incorporation = Incorporation, MockIncorporation
        $VERBOSE                              = old_verbose

        module Hittable
          # logic for hitting an object
        end

        module BasicBehavior
          class GameObject
            trait ({ some_definition: "of a trait" })
          end
        end

        Incorporation.instance.incorporated.should be_true

        # Silently switch back to original class
        old_verbose, $VERBOSE = $VERBOSE, nil
        Incorporation         = ORIGINAL_INCORPORATION
        $VERBOSE              = old_verbose
      end
    end
  end
end
