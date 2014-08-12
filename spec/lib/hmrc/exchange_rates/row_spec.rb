require 'spec_helper'
require 'hmrc/exchange_rates/row'

Row = Hmrc::ExchangeRates::Row

describe Row do
  context 'when input is bad' do
    context 'when is not a 3-valued array' do
      it 'fails' do
        expect{ Row.new([1, 2], nil) }.to raise_error(ArgumentError, /expects a 3-valued row/)
      end
    end
  end

  context 'when input is good' do
    let(:country)   { double 'country' }
    let(:euro_date) { nil }
    subject(:row) { Row.new(array, country) }

    before do
      country.stub(:currency).and_return('Greek Drachma')
      country.stub(:euro_date).and_return(euro_date)
    end

    context 'a normal array' do
      let(:array) { %w(31.03.99 0.45506 2.1975) }

      its(:country)        { should == country }
      its(:row)            { should == array }
      its(:sterling_value) { should == '0.45506' }
      its(:currency_per)   { should == '2.1975' }

      it 'transforms back to array with YYYY-MM-DD dates' do
        row.to_a.should == ['Average', '1998-03-31', '1999-03-31', '0.45506', '2.1975', 'Greek Drachma']
      end
    end

    context 'when the Euro date has been passed' do
      let(:array)     { %w(31.03.02 0.45506 2.1975) }
      let(:euro_date) { Date.new(2001, 1, 1) }

      it 'sets the currency appropriately' do
        row.to_a.should == ['Average', '2001-03-31', '2002-03-31', '0.45506', '2.1975', 'Euro']
      end
    end

    context 'a range of dates in the first column' do
      let(:array) { [
        '15.04.94 to 31.03.95',
        '0.0156146',
        '64.0424'
      ] }

      its(:sterling_value) { should == '0.0156146' }
      its(:currency_per)   { should == '64.0424' }

      its(:to_a) { should == ['Average', '1994-04-15', '1995-03-31', '0.0156146', '64.0424', 'Greek Drachma']}
    end

    context 'the French problem' do
      let(:array) {[
        'Average 1. 4.01 to 27. 2.02',
        '0.0941256201',
        '10.6241'
      ]}

      its(:sterling_value) { should == '0.0941256201' }
      its(:currency_per)   { should == '10.6241' }
      its(:to_a)      { should == ['Average', '2001-04-01', '2002-02-27', '0.0941256201', '10.6241', 'Greek Drachma']}
    end

    context 'whitespace all over the shop' do
      let(:array) {[
        '   Average 1. 4.01 to 27. 2.02  ',
        '  0.0941256201   ',
        '    10.6241    '
      ]}

      its(:sterling_value) { should == '0.0941256201' }
      its(:currency_per)   { should == '10.6241' }
      its(:to_a)      { should == ['Average', '2001-04-01', '2002-02-27', '0.0941256201', '10.6241', 'Greek Drachma']}
    end
  end
end
