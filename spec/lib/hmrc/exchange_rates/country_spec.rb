# encoding: utf-8

require 'spec_helper'

require 'hmrc/exchange_rates/country'
require 'nokogiri'

Country = Hmrc::ExchangeRates::Country

describe Country do
  describe '.parse' do
    context 'when the input is bad' do
      it 'requires a Nokogiri element' do
        expect { Country.parse(1) }.to raise_error(
                                         ArgumentError, /requires an HTML document/)
      end
    end

    context 'when the input is good' do
      describe 'the country' do
        subject(:country) do
          Country.parse(
            Nokogiri::HTML(
              File.read('spec/fixtures/exchange_rates/algeria.htm')
            )
          )
        end

        it { should be_a(Country) }

        its(:name)     { should == 'Algeria' }
        its(:currency) { should == 'Algerian Dinar' }

        describe 'its CSV' do
          subject (:csv) { country.csv }

          it { should be_an(Array) }

          it 'has a header row' do
            csv.should include ['Average for year to', 'Sterling value of currency unit - £', 'Currency units per £1']
          end

          it 'has value rows that transform the date' do
            csv.should include ['2014-03-31','0.0079','126.062557']
          end
        end
      end
    end
  end
end
