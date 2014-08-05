require 'spec_helper'
require 'hmrc/exchange_rates/row'

Row = Hmrc::ExchangeRates::Row

describe Row do
  context 'when input is bad' do
    context 'when is not a 3-valued array' do
      it 'fails' do
        expect{ Row.new([1, 2]) }.to raise_error(ArgumentError, /expects a 3-valued row/)
      end
    end
  end

  context 'when input is good' do
    subject(:row) { Row.new(array) }

    context 'a normal array' do
      let(:array) { %w(31.03.99 0.45506 2.1975) }

      its(:row)            { should == array }
      its(:from_date)      { should == Date.new(1998, 3, 31) }
      its(:to_date)        { should == Date.new(1999, 3, 31) }
      its(:sterling_value) { should == '0.45506' }
      its(:currency_per)   { should == '2.1975' }

      it 'transforms back to array with YYYY-MM-DD dates' do
        row.to_a.should == ['1999-03-31', '0.45506', '2.1975']
      end
    end

    context 'a range of dates in the first column' do
      let(:array) { [
        '15.04.94 to 31.03.95',
        '0.0156146',
        '64.0424'
      ] }

      its(:from_date) { should eql(Date.new(1994, 4, 15)) }
      its(:to_date)   { should eql(Date.new(1995, 3, 31)) }
      its(:sterling_value) { should == '0.0156146' }
      its(:currency_per)   { should == '64.0424' }

      its(:to_a) { should == ['1994-04-15 to 1995-03-31', '0.0156146', '64.0424']}
    end
  end
end
