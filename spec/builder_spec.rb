require_relative '../lib/method_aliasing'
require_relative '../lib/builder'
require_relative '../lib/trait'
require_relative '../lib/traits_home'
require_relative '../lib/core_extensions/string_and_symbol'
require_relative '../lib/core_extensions/array'
require_relative '../lib/core_extensions/hash'
require_relative '../lib/core_extensions/module'
require_relative '../lib/traitable'
require_relative '../lib/incorporation'

#noinspection RubyArgCount
#noinspection RubyResolve
module Traits
  describe Builder do

    module MovableForBuilder


      def to_s
        'movable'
      end

      def moved?
        true
      end
    end

    module ScalableForBuilder

      def to_s
        'scalable'
      end

      def scale
        0
      end
    end

    module HittableForBuilder

      def to_s
        'hittable'
      end

    end

    module ShootingForBuilder

    end

    class Football
      include Traitable
    end

    it 'should respond only to DSL methods' do
      dsl_methods = [:trait,
                     :traits,
                     :with_options,
                     :resolve,
                     :resolves,
                     :with_lambda,
                     :with_pattern,
                     :call_in_order,
                     :done,
                     :do_it,
                     :incorporate,
                     :and,
                     :build,
                     :incorporation,
                     :except,
                     :only,
                     :but_only,
                     :manually]
      Builder.new(Football).should respond_to(*dsl_methods)

      Builder.new(Football).public_methods(false).should include(*dsl_methods)

      Builder.new(Football).public_methods(false).should have(dsl_methods.size).dsl_methods
    end
    build = -> do
      Builder.new(Football).trait(:movable_for_builder).with_options(except: :to_s).trait(:scalable_for_builder).traits(:hittable_for_builder, :shooting_for_builder).resolves(:moved?).with_lambda(-> { raise "not really resolved" }).resolves(:to_s).with_pattern.call_in_order.build
    end

    it 'raises no error' do
      build.should_not raise_error (RuntimeError)
      build.call.should be_instance_of(Incorporation)
    end

    incorporation = build.call

    it 'builds proper traits ad options' do
      incorporation.traits.should have(4).traits
      incorporation.traits.should include(Trait[MovableForBuilder],
                                          Trait[ScalableForBuilder],
                                          Trait[HittableForBuilder],
                                          Trait[ShootingForBuilder])
      incorporation.traits[Trait[MovableForBuilder]].should have(1).option_except
      incorporation.traits[Trait[MovableForBuilder]].keys.first.should == :except
      incorporation.traits[Trait[ScalableForBuilder]].should be_empty
      incorporation.traits[Trait[HittableForBuilder]].should be_empty
      incorporation.traits[Trait[ShootingForBuilder]].should be_empty
    end

    it 'builds proper resolves' do
      incorporation.resolves.should have(2).resolves
      incorporation.resolves.keys.should include(:moved?, :to_s)
      incorporation.resolves.values.all? { |resolve| resolve.is_a? Proc }.should be_true
    end

  end

end


