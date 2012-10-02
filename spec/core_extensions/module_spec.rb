require_relative '../../lib/core_extensions/module'

describe Module do
  describe 'fetch' do
    module Corporation
      module HumanResource

      end
    end

    it 'returns a valid constant' do
      #noinspection RubyResolve
      Corporation.const_fetch(:HumanResource).should == Corporation::HumanResource
    end

    it 'returns the alternative when not found' do
      #noinspection RubyResolve
      Corporation.const_fetch(:Finance, "sorry, we have no finance department").should == "sorry, we have no finance department"
    end

    it 'executes block when not found and no alternative' do
      #noinspection RubyResolve
      Corporation.const_fetch(:Finance) { "how do you even operate without a finance department?" }.should == "how do you even operate without a finance department?"
    end

    it 'returns the alternative when not found and block is given' do
      #noinspection RubyResolve
      Corporation.const_fetch(:Finance, "Hello, I'm the brand new HumanResource department") { "No its not" }.should == "Hello, I'm the brand new HumanResource department"
    end

    it 'returns the valid constant even when alternative and block is given' do
      #noinspection RubyResolve
      Corporation.const_fetch(:HumanResource, "Im the Human Resource") { "No I am" }.should == Corporation::HumanResource
    end
  end
end
