require_relative '../lib/traitable'
require_relative '../lib/trait'
require_relative '../lib/core_extensions/module'
require_relative '../lib/core_extensions/string_and_symbol'
require_relative '../lib/traits_home'

describe ::Traits::Trait do
  before :each do
    # Dont give warnings when overwriting the constant - only during this test!
    old_verbose, $VERBOSE = $VERBOSE, nil
    ::Traits.const_set(:TestTrait, Module.new)
    $VERBOSE = old_verbose
  end

  it 'should be constructable with trait look up' do
    trait = ::Traits::Trait[:TestTrait]
    trait.module.should be_instance_of(Module)

  end

  it 'should be constructable with actual trait' do
    trait = ::Traits::Trait.new(::Traits::TestTrait)
    trait.should be_instance_of ::Traits::Trait
  end

  it 'should access instance methods' do
    module ::Traits::TestTrait
      def a_trait_method
        "a_trait_method"
      end

      def another_trait_method
        "another_trait_method"
      end
    end

    trait = ::Traits::Trait[:TestTrait]
    trait.instance_methods.should have(2).entries
    trait.instance_methods.should include(:a_trait_method, :another_trait_method)

  end

  it 'should have a simple name' do
    trait = ::Traits::Trait.new(:TestTrait)
    trait.simple_name.should == "TestTrait"
  end

  it 'can alias methods with its own suffix' do
    module ::Traits::TestTrait
      def a_trait_method
        "a_trait_method"
      end

      def another_trait_method
        "another_trait_method"
      end
    end

    trait = ::Traits::Trait[:TestTrait]
    trait.alias_methods(:a_trait_method, :this_method_does_not_exist)
    trait.instance_methods.should have(3).entries
    trait.instance_methods.should include(:a_trait_method, :another_trait_method, :a_trait_method_in_test_trait)
  end

  it 'should alias methods with ? and ! with its own suffix' do
    module ::Traits::TestTraitWithQuestionMarkAndBang
      def sure?
        @sure
      end

      def sure!
        @sure = true
      end
    end

    trait = ::Traits::Trait[:TestTraitWithQuestionMarkAndBang]
    trait.alias_methods(:sure?, :sure!)
    trait.instance_methods.should have(4).entries
    trait.instance_methods.should include(:sure?, :sure!, :sure_in_test_trait_with_question_mark_and_bang?, :sure_in_test_trait_with_question_mark_and_bang!)
  end

end

