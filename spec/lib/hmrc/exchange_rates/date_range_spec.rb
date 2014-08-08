require 'spec_helper'
require 'hmrc/exchange_rates/date_range'

DateRange = Hmrc::ExchangeRates::DateRange

describe DateRange do
  describe '.parse' do
    context 'when an unrecognised format' do
      it 'fails' do
        expect{DateRange.parse('rubbish').from_date}.to raise_error(ArgumentError,
                                              /unrecognised format/)
      end
    end

    subject(:range) { DateRange.parse(input) }

    context 'when a single date from last century' do
      let(:input) { '23.04.97' }

      it 'sets its from_date to a year in the past' do
        range.from_date.should == Date.new(1996, 4, 23)
      end
      its(:to_date)   { should == Date.new(1997, 4, 23) }
    end

    context 'when a spot rate on a date' do
      let(:input) { 'Spot rate on 30. 3.94' }

      its(:to_date)   { should == Date.new(1994, 3, 30) }
      its(:from_date) { should be_nil}
    end

    context 'when a range of dates' do
      let(:input) { '15.04.94 to 31.03.95' }

      its(:from_date) { should == Date.new(1994, 4, 15)}
      its(:to_date)   { should == Date.new(1995, 3, 31)}
    end

    context 'when a Euro range of dates' do
      let(:input) { 'Euro from 1. 1.02 to 28. 3.02' }

      its(:from_date) { should == Date.new(2002,1,1)}
      its(:to_date)   { should == Date.new(2002,3,28)}
    end

    context 'when an average range with a mad date format' do
      let(:input) { 'Average 1. 4.01 to 27. 2.02' }

      its(:from_date) { should == Date.new(2001, 4, 1)}
      its(:to_date)   { should == Date.new(2002, 2, 27)}
    end

    context 'when an average single date with a mad date format' do
      let(:input) { 'Average for year to 31. 3.01' }

      its(:from_date) { should == Date.new(2000, 3, 31)}
      its(:to_date)   { should == Date.new(2001, 3, 31)}
    end
  end
end
