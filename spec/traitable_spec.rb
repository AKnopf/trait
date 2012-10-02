#require_relative '../../../lib/chingu/traits/traitable/trait'
#require_relative '../../../lib/chingu/traits/traitable/traitable'
#require_relative '../../../lib/chingu/vector'
#require_relative '../../../lib/chingu/core_ext/module'
#
#module Chingu
#
#  describe Traits::Traitable do
#
#    describe 'basic behavior' do
#      module BasicBehavior
#        class GameObject
#          include ::Chingu::Traits::Traitable
#        end
#      end
#
#      describe 'home' do
#        module MyGame
#          module MyTraits
#            module MyTrait
#            end
#          end
#
#          ::Chingu::Traits::HOME << MyGame::MyTraits
#
#          class MyGameObject
#
#            include ::Chingu::Traits::Traitable
#
#            trait :my_trait
#
#          end
#        end
#        it 'should find traits in Traits::HOME' do
#          MyGame::MyGameObject.included_modules.should include(MyGame::MyTraits::MyTrait)
#        end
#      end
#
#      describe 'class macros' do
#        it 'should have method "trait" and "traits"' do
#          BasicBehavior::GameObject.should respond_to(:trait, :traits)
#        end
#      end
#
#    end
#
#
#    describe 'incorporation' do
#
#      describe 'attributes' do
#        module Traits
#          module Moving
#            Attributes = { position: Vector[0, 0],
#                           speed:    Vector[0, 0] }
#          end
#        end
#
#        module Incorporation
#          class Bullet
#            include Traits::Traitable
#            trait :moving, speed: Vector[100, 0]
#
#            def self.create(*args)
#              new *args
#            end
#
#            def initialize(options = { })
#              setup options
#            end
#
#            def setup(options)
#              setup_trait options
#            end
#          end
#        end
#
#        it 'should overwrite all defaults' do
#          bullet = Incorporation::Bullet.create(position: Vector[100, 100], speed: Vector[50, 0])
#          bullet.position.should == Vector[100, 100]
#          bullet.speed.should == Vector[50, 0]
#        end
#
#        it 'should accept class defaults' do
#          bullet = Incorporation::Bullet.create(position: Vector[100, 100])
#          bullet.position.should == Vector[100, 100]
#          bullet.speed.should == Vector[100, 0]
#        end
#
#        it 'should accept trait defaults' do
#          bullet = Incorporation::Bullet.create
#          bullet.position.should == Vector[0, 0]
#          bullet.speed.should == Vector[100, 0]
#        end
#
#        it 'class defaults should overwrite trait defaults' do
#          bullet = Incorporation::Bullet.create
#          bullet.position.should == Vector[0, 0]
#          bullet.speed.should == Vector[100, 0]
#        end
#
#        describe 'conflicts' do
#          module Traits
#            module Translatable
#              Attributes = { language: :english }
#            end
#            module Interpretable
#              Attributes = { language: :ruby }
#            end
#          end
#          module CollidingAttributes
#            class GameObject
#              include ::Chingu::Traits::Traitable
#            end
#
#          end
#
#          it 'should detect conflicting attributes' do
#            incorporate = -> do
#              class CollidingAttributes::GameObject
#                traits :translatable, :interpretable
#              end
#            end
#            incorporate.should raise_error
#          end
#        end
#      end
#    end
#  end
#end
