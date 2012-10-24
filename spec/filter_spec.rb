require_relative '../lib/filter'

#noinspection ALL
module Traits
  describe 'Filter' do
    module FirstModule
      def hello
        "hello in FirstModule"
      end

      def goodbye
        "goodbye in FirstModule"
      end
    end

    module SecondModule
      def hello
        "hello in SecondModule"
      end

      def goodbye
        "goodbye in SecondModule"
      end
    end

    it 'causes a module to be skipped in the method lookup for :except methods [ExceptFilter]' do
      class Base
      end

      FirstModuleFilterForBase = ExceptFilter[Base, FirstModule, :hello]

      class Base
        include SecondModule
        include FirstModule
        include FirstModuleFilterForBase
      end


      base = Base.new

      base.hello.should == "hello in SecondModule"

    end

    it 'causes a module to be skilled in the method lookup for not :only methods [OnlyFilter]' do
      class AnotherBase

      end

      FirstModuleFilterForAnotherBase = OnlyFilter[Base, FirstModule, :goodbye]

      class AnotherBase
        include SecondModule
        include FirstModule
        include FirstModuleFilterForAnotherBase
      end

      base = Base.new

      base.hello.should == "hello in SecondModule"
    end
  end
end
