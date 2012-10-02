require_relative '../lib/incorporation'
require_relative '../lib/trait'
require_relative '../lib/traitable'
require_relative '../lib/resolve'
require_relative '../lib/core_extensions/can_be_constant'
require_relative '../lib/core_extensions/module'
require_relative '../lib/core_extensions/array'
require_relative '../lib/core_extensions/hash'

module Traits


  describe Incorporation do
    def generic_traitable_class
      Class.new.send(:include, Traitable)
    end


    module Movable

    end

    it 'should be constructable via a big hash' do
      create_via_big_hash = -> do
        Incorporation[traits:               [:movable],
                      resolves:             { [:draw, :update, :setup] => { } },
                      class_level_resolves: { },
                      incorporator:         generic_traitable_class
        ]

        create_via_big_hash.should_not raise_error
      end
    end

    it 'requires a mandatory incorporator' do
      create = -> do
        Incorporation[traits:               :movable,
                      resolves:             { },
                      class_level_resolves: { }]
      end
      create.should raise_error
    end

    it 'should be constructable via separate arguments' do
      create_via_arguments = -> do
        Incorporation[[:movable],
                      { [:draw, :update, :setup] => { } },
                      { },
                      generic_traitable_class]
      end
      create_via_arguments.should_not raise_error
    end

    it 'should accept a single trait as a plain symbol' do
      create = -> do
        Incorporation[traits:               :movable,
                      resolves:             { [:draw, :update, :setup] => { } },
                      class_level_resolves: { },
                      incorporator:         generic_traitable_class]

      end

      create.should_not raise_error
    end

    it 'should accept a single trait as a plain module' do
      create = -> do
        Incorporation[traits:               Movable,
                      resolves:             { [:draw, :update, :setup] => { } },
                      class_level_resolves: { },
                      incorporator:         generic_traitable_class]
      end
      create.should_not raise_error
    end

    it 'should accept no resolves given' do
      create = -> do
        Incorporation[traits:               Movable,
                      class_level_resolves: { },
                      incorporator:         generic_traitable_class]
      end
      create.should_not raise_error
      #noinspection RubyArgCount
      create.call.resolves.should be_empty
    end

    it 'should accept arrays as resolve matcher' do
      create = -> do
        Incorporation[traits:               Movable,
                      resolves:             { [:draw, :update, :setup] => { } },
                      class_level_resolves: { },
                      incorporator:         generic_traitable_class]
      end
      create.should_not raise_error
      #noinspection RubyArgCount
      actual_resolves = create.call.resolves
      actual_resolves.should have(3).matchers
      actual_resolves.should include(:draw, :update, :setup)
      actual_resolves.values.all? { :empty? }.should be_true
    end

    it 'should accept no class_level_resolves given' do
      create = -> do
        Incorporation[traits:       Movable,
                      resolves:     { },
                      incorporator: generic_traitable_class]
      end
      create.should_not raise_error
      #noinspection RubyArgCount
      create.call.class_level_resolves.should be_empty
    end

    it 'should accept arrays as class_level_resolves matcher' do
      create = -> do
        Incorporation[traits:               Movable,
                      class_level_resolves: { [:draw, :update, :setup] => { } },
                      resolves:             { },
                      incorporator:         generic_traitable_class]
      end
      create.should_not raise_error
      #noinspection RubyArgCount
      actual_resolves = create.call.class_level_resolves
      actual_resolves.should have(3).matchers
      actual_resolves.should include(:draw, :update, :setup)
      actual_resolves.values.all? { :empty? }.should be_true
    end

    module Movable
      def moved?

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
      incorporation = Incorporation[traits:               [:movable, :emotion],
                                    resolves:             { },
                                    class_level_resolves: { },
                                    incorporator:         generic_traitable_class]
      incorporation.colliding_methods.should have(1).entry
      incorporation.colliding_methods.should include(:moved?)
    end

    it 'should detect unresolved collisions' do
      incorporation = Incorporation[traits:               [:movable, :emotion],
                                    resolves:             { },
                                    class_level_resolves: { },
                                    incorporator:         generic_traitable_class]
      incorporation.unresolved_colliding_methods.should have(1).entry
      incorporation.unresolved_colliding_methods.should include(:moved?)

      incorporation = Incorporation[traits:               [:movable, :emotion],
                                    resolves:             { moved?: { } },
                                    class_level_resolves: { },
                                    incorporator:         generic_traitable_class]
      incorporation.unresolved_colliding_methods.should have(0).entries

    end

    it 'should raise error when incorporated with unresolved conflicts' do
      wrong_incorporation = -> { Incorporation[traits:               [:movable, :emotion],
                                               resolves:             { },
                                               class_level_resolves: { },
                                               incorporator:         generic_traitable_class].incorporate }
      wrong_incorporation.should raise_error
    end

    it 'should alias conflicted methods in traits upon incorporation' do
      Incorporation[traits:               [:movable, :emotion],
                    resolves:             { moved?: { } },
                    class_level_resolves: { },
                    incorporator:         generic_traitable_class].incorporate
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

      incorporation = Incorporation[traits:               :movable,
                                    resolves:             { },
                                    class_level_resolves: { },
                                    incorporator:         Bullet]

      #raise incorporation.colliding_methods.inspect
      #raise Bullet.instance_methods(false).inspect
      incorporation.colliding_methods.should have(1).entry
      incorporation.colliding_methods.should include(:direction)


    end


  end


end
