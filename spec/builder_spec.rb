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
                     :incorporation]
      Builder.new(Football).should respond_to(*dsl_methods)

      Builder.new(Football).public_methods(false).should include(*dsl_methods)

      Builder.new(Football).public_methods(false).should have(dsl_methods.size).dsl_methods
    end

    it 'should construct a valid Incorporation' do
      build = -> do
        Builder.new(Football).trait(:movable_for_builder).with_options(except: :to_s).trait(:scalable_for_builder).traits(:hittable_for_builder, :shooting_for_builder).resolves(:moved?).with_lambda(-> { raise "not really resolved" }).resolves(:to_s).with_pattern.call_in_order.build
      end
      build.should_not raise_error (RuntimeError)
      build.call.should be_instance_of(Incorporation)
    end


  end

end


