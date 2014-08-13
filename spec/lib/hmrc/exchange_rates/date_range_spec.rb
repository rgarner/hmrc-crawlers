require 'spec_helper'
require 'hmrc/exchange_rates/date_range'

DateRange = Hmrc::ExchangeRates::DateRange

describe DateRange do
  context 'when an unrecognised format' do
    it 'fails' do
      expect { DateRange.new('rubbish').from_date }.to raise_error(ArgumentError,
                                                                   /unrecognised format/)
    end
  end

  subject(:range) { DateRange.new(input) }

  context 'when a single date from last century' do
    let(:input) { '23.04.97' }

    its(:type)    { should == :average }
    it 'sets its from_date to a year in the past' do
      range.from_date.should == Date.new(1996, 4, 23)
    end
    its(:to_date) { should == Date.new(1997, 4, 23) }
  end

  context 'when a spot rate on a date' do
    let(:input) { 'Spot rate on 30. 3.94' }

    its(:type)      { should == :spot}
    its(:to_date)   { should == Date.new(1994, 3, 30) }
    its(:from_date) { should be_nil }
    it 'should not try to format the from date' do
      range.format(:from_date).should be_nil
    end
  end

  context 'when a range of dates' do
    let(:input) { '15.04.94 to 31.03.95' }

    its(:type)      { should == :average }
    its(:from_date) { should == Date.new(1994, 4, 15) }
    its(:to_date)   { should == Date.new(1995, 3, 31) }

    it 'can format the from date' do
      range.format(:from_date).should == '1994-04-15'
    end
    it 'can format the to date' do
      range.format(:to_date).should == '1995-03-31'
    end
  end

  context 'when a Euro range of dates' do
    let(:input) { 'Euro from 1. 1.02 to 28. 3.02' }

    its(:type)      { should == :average}
    its(:from_date) { should == Date.new(2002, 1, 1) }
    its(:to_date)   { should == Date.new(2002, 3, 28) }
  end

  context 'when an average range with a mad date format' do
    let(:input) { 'Average 1. 4.01 to 27. 2.02' }

    its(:type)      { should == :average }
    its(:from_date) { should == Date.new(2001, 4, 1) }
    its(:to_date)   { should == Date.new(2002, 2, 27) }
  end

  context 'when an average range with a mad date format' do
    let(:input) { 'Average for 15.1.94 to 30. 3.94' }

    its(:type)      { should == :average }
    its(:from_date) { should == Date.new(1994, 1, 15) }
    its(:to_date)   { should == Date.new(1994, 3, 30) }
  end

  context 'when an average range with a mad *and* inconsistent date format' do
    let(:input) { 'Average for 01/07/05 - 31/03/06' }

    its(:type)      { should == :average }
    its(:from_date) { should == Date.new(2005, 7, 1) }
    its(:to_date)   { should == Date.new(2006, 3, 31) }
  end

  context 'when an average range for only half a date' do
    context 'when a month ending in 31' do
      let(:input) { 'Average for 09.01 to 03.02' }

      its(:type)      { should == :average }
      it 'goes from the start of the first month' do
        range.from_date.should == Date.new(2001, 9, 1)
      end
      it 'goes to the end of the second' do
        range.to_date.should == Date.new(2002, 3, 31)
      end
    end

    context 'when a non-leap year' do
      let(:input) { 'Average for 01.01 to 02.01' }

      its(:type) { should == :average }

      it 'goes from the start of the first month' do
        range.from_date.should == Date.new(2001, 1, 1)
      end
      it 'goes to the end of February - 28th' do
        range.to_date.should == Date.new(2001, 2, 28)
      end
    end

    context 'when a leap year' do
      let(:input) { 'Average for 01.12 to 02.12' }

      its(:type) { should == :average }

      it 'goes from the start of the first month' do
        range.from_date.should == Date.new(2012, 1, 1)
      end
      it 'goes to the end of February - 28th' do
        range.to_date.should == Date.new(2012, 2, 29)
      end
    end
  end

  context 'when an average single date with a mad date format' do
    let(:input) { 'Average for year to 31. 3.01' }

    its(:type)      { should == :average }
    its(:from_date) { should == Date.new(2000, 3, 31) }
    its(:to_date)   { should == Date.new(2001, 3, 31) }
  end

  context 'Honduras has a month after December' do
    let(:input) { '31.13.06' }

    its(:type)      { should == :average }

    it 'corrects the to_date' do
      range.to_date.should == Date.new(2006, 12, 31)
    end
    its(:from_date) { should == Date.new(2005, 12, 31) }
  end

  context 'Market/Official averages' do
    context 'market' do
      let(:input) { 'Average for year to 31. 3.96 (Market)' }
      its(:type)  { should == :'average/market'}
    end

    context 'official' do
      let(:input) { 'Average for year to 31. 3.96 (Official)' }
      its(:type)  { should == :'average/official'}
    end
  end
end
