require_relative '../lib/trait'
require_relative '../lib/traitable'
require_relative '../lib/core_extensions/can_be_constant'
require_relative '../lib/core_extensions/module'
require_relative '../lib/resolve'


module Traits

  module Movable

  end

  module Hittable

  end

  describe Resolve do
    it 'should be constructable with a lambda' do
      create = -> { Resolve[nil, nil, nil, -> { puts "resolved!" }] }
      create.should_not raise_error
    end

    it 'should be constructable with the manually method' do
      create = -> { Resolve.manually { "resolved!" } }
      create.should_not raise_error
      #noinspection RubyArgCount
      create.call.lambda.call.should == "resolved!"
    end

    it 'should be constructable with a pattern' do
      create = -> { Resolve[[:movable, :hittable], :inject, :^] }
      create.should_not raise_error
      #noinspection RubyArgCount
      resolve = create.call
      resolve.order.should include(Trait[:movable], Trait[:hittable])
      resolve.order.should have(2).traits
      resolve.link_mode.should == :inject
      resolve.link_operator.should == :^
    end

    it 'should be constructable with a big hash' do
      create = -> { Resolve[order:         [:movable, :hittable],
                            link_mode:     :inject,
                            link_operator: :^] }
      create.should_not raise_error
      #noinspection RubyArgCount
      resolve = create.call
      resolve.order.should include(Trait[:movable], Trait[:hittable])
      resolve.order.should have(2).traits
      resolve.link_mode.should == :inject
      resolve.link_operator.should == :^
    end
  end

end

