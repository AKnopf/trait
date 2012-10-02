require_relative '../../lib/core_extensions/can_be_constant'

#noinspection ALL
module NoInpsection
  describe CanBeConstant do

    expected = :ThisIsAConstant

    it 'should convert Symbols to constants' do
      :this_is_a_constant.to_constant.should == expected
      :thisIsAConstant.to_constant.should == expected
      :this___Is_A__Constant.to_constant.should == expected
    end

    it 'should convert Strings to constants' do
      'this_is_a_constant'.to_constant.should == expected
      'thisIsAConstant'.to_constant.should == expected
      'this___Is_A__Constant'.to_constant.should == expected
      'this is a constant'.to_constant.should == expected
    end

    expected_snake_case = 'this_is_a_constant'
    it 'should convert Constants to snake case' do
      'this_is_a_constant'.to_snake_case.should == expected_snake_case
      'this___Is_A__Constant'.to_snake_case.should == expected_snake_case
      'this is a constant'.to_snake_case.should == expected_snake_case
      'TestTrait'.to_snake_case.should == 'test_trait'
    end
  end
end
