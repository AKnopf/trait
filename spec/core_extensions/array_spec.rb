require_relative '../../lib/core_extensions/array'

#noinspection ALL
module NoInpsection
  describe Array do

    before (:each) do
      @week                = [:mo, :tu, :we, :th, :fr, :sa, :su]
      @two_weeks           = [:mo, :tu, :we, :th, :fr, :sa, :su, :mo, :tu, :we, :th, :fr, :sa, :su]
      @many_mondays        = [:mo, :mo, :mo, :mo]
      @one_and_a_half_week = [:mo, :tu, :we, :th, :fr, :sa, :su, :mo, :tu, :we]

    end

    describe 'duplicates' do

      it 'detects duplicates' do
        @week.duplicates.should be_empty
        @two_weeks.duplicates.should == @week
        @many_mondays.duplicates.should == [:mo]
        @one_and_a_half_week.duplicates.should == [:mo, :tu, :we]

        @week.duplicates!.should be_empty
        @two_weeks.duplicates!.should == [:mo, :tu, :we, :th, :fr, :sa, :su]
        @many_mondays.duplicates!.should == [:mo]
        @one_and_a_half_week.duplicates!.should == [:mo, :tu, :we]
      end

      it 'is idempotent' do
        @week.duplicates
        @week.should == [:mo, :tu, :we, :th, :fr, :sa, :su]
      end

      it 'is destructive with bang' do
        @week.duplicates!
        @week.should be_empty
      end
    end
  end
end
