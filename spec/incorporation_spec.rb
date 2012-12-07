require_relative '../lib/core_extensions/module'
require_relative '../lib/core_extensions/array'
require_relative '../lib/core_extensions/hash'
require_relative '../lib/core_extensions/string_and_symbol'

require_relative '../lib/method_aliasing'
require_relative '../lib/incorporation'
require_relative '../lib/trait'
require_relative '../lib/traitable'
require_relative '../lib/traits_home'
require_relative '../lib/filter'

#noinspection ALL
module Traits


  describe Incorporation do
    def generic_traitable_class
      Class.new.send(:include, Traitable)
    end


    module Movable

    end

    it 'should be constructable via a big hash' do
      create_via_big_hash = -> do
        Incorporation[traits:       [:movable],
                      resolves:     { [:draw, :update, :setup] => { } },
                      incorporator: generic_traitable_class
        ]

        create_via_big_hash.should_not raise_error
      end
    end

    it 'requires a mandatory incorporator' do
      create = -> do
        Incorporation[traits:   :movable,
                      resolves: { }]
      end
      create.should raise_error
    end

    it 'should be constructable via separate arguments' do
      create_via_arguments = -> do
        Incorporation[[:movable],
                      { [:draw, :update, :setup] => { } },
                      generic_traitable_class]
      end
      create_via_arguments.should_not raise_error
    end

    it 'should accept a single trait as a plain symbol' do
      create = -> do
        Incorporation[traits:       :movable,
                      resolves:     { [:draw, :update, :setup] => { } },
                      incorporator: generic_traitable_class]

      end

      create.should_not raise_error
    end

    it 'should accept a single trait as a plain module' do
      create = -> do
        Incorporation[traits:       Movable,
                      resolves:     { [:draw, :update, :setup] => { } },
                      incorporator: generic_traitable_class]
      end
      create.should_not raise_error
    end

    it 'should accept no resolves given' do
      create = -> do
        Incorporation[traits:       Movable,
                      incorporator: generic_traitable_class]
      end
      create.should_not raise_error
      #noinspection RubyArgCount
      create.call.resolves.should be_empty
    end

    it 'should accept arrays as resolve matcher' do
      create = -> do
        Incorporation[traits:       Movable,
                      resolves:     { [:draw, :update, :setup] => { } },
                      incorporator: generic_traitable_class]
      end
      create.should_not raise_error
      #noinspection RubyArgCount
      actual_resolves = create.call.resolves
      actual_resolves.should have(3).matchers
      actual_resolves.should include(:draw, :update, :setup)
      actual_resolves.values.all? { :empty? }.should be_true
    end

    module Movable
      def moved?
        "moved in movable"
      end

      def direction

      end
    end

    module Emotion
      def moved?

      end

      def joy_level

      end
    end

    it 'should detect colliding method names' do
      incorporation = Incorporation[traits:       [:movable, :emotion],
                                    resolves:     { },
                                    incorporator: generic_traitable_class]
      incorporation.colliding_methods.should have(1).entry
      incorporation.colliding_methods.should include(:moved?)
    end

    it 'should detect unresolved collisions' do
      incorporation = Incorporation[traits:       [:movable, :emotion],
                                    resolves:     { },
                                    incorporator: generic_traitable_class]
      incorporation.unresolved_colliding_methods.should have(1).entry
      incorporation.unresolved_colliding_methods.should include(:moved?)

      incorporation = Incorporation[traits:       [:movable, :emotion],
                                    resolves:     { moved?: { } },
                                    incorporator: generic_traitable_class]
      incorporation.unresolved_colliding_methods.should have(0).entries

    end

    it 'should raise error when incorporated with unresolved conflicts' do
      wrong_incorporation = -> { Incorporation[traits:       [:movable, :emotion],
                                               resolves:     { },
                                               incorporator: generic_traitable_class].incorporate }
      wrong_incorporation.should raise_error
    end

    it 'should alias conflicted methods in traits upon incorporation' do
      Incorporation[traits:       [:movable, :emotion],
                    resolves:     { moved?: -> { raise :moved } },
                    incorporator: generic_traitable_class].incorporate
      #raise Trait[:movable].instance_methods.inspect
      Trait[:movable].instance_methods.should include(:moved?, :direction, :moved_in_movable?)
      Trait[:movable].instance_methods.should have(3).entries
      Trait[:emotion].instance_methods.should include(:moved?, :joy_level, :moved_in_emotion?)
      Trait[:emotion].instance_methods.should have(3).entries
    end

    it 'should detect method conflicts between the incorporator and the trait' do
      class Bullet
        include Traitable

        def direction

        end
      end

      incorporation = Incorporation[traits:       :movable,
                                    resolves:     { },
                                    incorporator: Bullet]

      #raise incorporation.colliding_methods.inspect
      #raise Bullet.instance_methods(false).inspect
      incorporation.colliding_methods.should have(1).entry
      incorporation.colliding_methods.should include(:direction)


    end


    describe 'actual incorporation' do

      it 'resolves conflicts among traits when there is no method in the class' do

        class Truck
          include Traitable
          trait(traits:       [:movable, :emotion],
                incorporator: self,
                resolves:     { moved?: -> { moved_in_movable? } })
        end

        truck = Truck.new

        truck.moved?.should == "moved in movable"
      end

      it 'ignores resolves that are not neccessary' do

        module Workshop
          def repair
            "clonk"
          end
        end

        class Truck
          include Traitable
          trait(traits:       [:movable, :emotion, :workshop],
                incorporator: self,
                resolves:     { moved?: -> { moved_in_movable? },
                                repair: -> { "clank" } })
        end

        truck = Truck.new

        truck.repair.should == "clonk"

      end

      it 'enables instance methods when there are no collisions' do
        module Hittable
          def hit(damage)
            self.health -= damage
          end
        end


        class Monster
          include Traitable

          attr_accessor :health

          def initialize
            self.health = 10
          end

          trait(traits:       [:hittable, :movable],
                incorporator: self,
                resolves:     { })
        end

        monster = Monster.new
        monster.should respond_to(:hit, :moved?, :direction)

        monster.hit(4)
        monster.health.should == 6
      end

      it 'requires conflicted methods to be resolved' do
        class Fish
          include Traitable
        end

        no_resolves = -> do
          class Fish
            trait(traits:       [:movable, :emotion],
                  incorporator: self,
                  resolves:     { })
          end
        end

        no_resolves.should raise_error

      end

      it 'resolves methods with a simple lambda' do
        class Fish
          trait(traits:       [:movable, :emotion],
                incorporator: self,
                resolves:     { moved?: -> { "resolved without use of original implementations" } }
          )
        end

        Fish.new.moved?.should == "resolved without use of original implementations"
      end

      it 'evals resolve lambdas in instance context' do
        class Programmer
          include Traitable

          attr_accessor :chips_eaten, :size_of_bag_of_chips


          def initialize chips_eaten, size_of_bag_of_chips
            self.chips_eaten          = chips_eaten
            self.size_of_bag_of_chips = size_of_bag_of_chips
          end

          trait(traits:       [:movable, :emotion],
                incorporator: self,
                resolves:     { moved?: -> { chips_eaten >= size_of_bag_of_chips } }
          )
        end

        hungry_programmer    = Programmer.new(0, 40)
        satisfied_programmer = Programmer.new(42, 40)

        hungry_programmer.should_not be_moved
        satisfied_programmer.should be_moved

      end


      it 'can access original versions of the conflicted method' do
        module Dessert
          def ingredients
            [:sugar, :milk, :chocolate]
          end
        end

        module Entree
          def ingredients
            [:wine, :pasta]
          end
        end


        class Meal
          include Traitable

          trait(traits:       [:dessert, :entree],
                incorporator: self,
                resolves:     { ingredients: -> { ingredients_in_dessert + ingredients_in_entree } }
          )
        end

        meal = Meal.new
        meal.ingredients.should have(5).ingredients
        meal.ingredients.should include(:wine, :pasta, :sugar, :milk, :chocolate)
      end

      it 'can resolve methods that use blocks' do
        module UsefulEnumerable
          def each_second(&block)
            second = false
            each do |elem|
              block.call elem if second
              second = !second
            end
          end
        end

        module Timer
          def each_second(&block)
            # some timer things...
            block.call self
          end
        end

        class UsefulArray < Array
          include Traitable

          trait(traits:       [:useful_enumerable, :timer],
                incorporator: self,
                resolves:     { each_second: lambda { |&block| each_second_in_useful_enumerable(&block) } }
          )

        end

        array = UsefulArray.new
        array << :a << :b << :c
        selection = []
        array.each_second do |elem|
          selection << elem
        end
        selection.should have(1).entries
      end


      it 'can incorporate only a few methods via :only' do
        module ABigTrait
          def the_wanted_method

          end

          def the_unwanted_method

          end
        end

        class ANeatClass
          include Traitable
          trait(traits:       { a_big_trait: { only: :the_wanted_method } },
                incorporator: self)
        end

        a_neat_object = ANeatClass.new
        -> { a_neat_object.the_wanted_method }.should_not raise_error
        -> { a_neat_object.the_unwanted_method }.should raise_error(NameError)
      end

      it 'can incorporate only a few methods via :except' do
        class ANiftyClass
          include Traitable
          trait(traits:       { a_big_trait: { except: :the_unwanted_method } },
                incorporator: self)
        end

        a_nifty_object = ANiftyClass.new
        -> { a_nifty_object.the_wanted_method }.should_not raise_error
        -> { a_nifty_object.the_unwanted_method }.should raise_error(NameError)
      end


    end

  end


end
