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
      subject(:country) do
        Country.parse(
          Nokogiri::HTML(
            File.read("spec/fixtures/exchange_rates/#{country_name}.html")
          )
        )
      end

      context 'Algeria' do
        let(:country_name) { 'algeria' }

        its(:name) { should == 'Algeria' }
        its(:currency) { should == 'Algerian Dinar' }

        describe 'its rows' do
          subject (:rows) { country.rows }

          it { should be_an(Array) }

          it { should have(53).rows }

          it 'has a header row' do
            rows.should include ['Average for year to', 'Sterling value of currency unit - £', 'Currency units per £1']
          end

          it 'has value rows that transform the date' do
            rows.should include ['2014-03-31', '0.0079', '126.062557']
          end

          it 'has value rows that transform last-century values' do
            FIRST_LAST_CENTURY_ROW = 30
            rows[FIRST_LAST_CENTURY_ROW].should == ['1999-12-30', '0.0093322408', '107.1554']
          end

          it 'has date ranges that transform' do
            FIRST_RANGE_ROW = 39
            rows[FIRST_RANGE_ROW].should == ['1994-04-15 to 1995-03-31', '0.0156146', '64.0424']
          end
        end

        describe 'its to_csv' do
          subject(:to_csv) { country.to_csv }

          it 'has a header row' do
            to_csv.should include "Average for year to,Sterling value of currency unit - £,Currency units per £1\n"
          end

          it 'has value rows that transform the date' do
            to_csv.should include "1999-12-30,0.0093322408,107.1554\n"
          end
        end
      end

      context 'France' do
        let(:country_name) { 'france' }

        it 'finds the table within the table' do
          country.table_node['width'].should == '589'
        end

        describe 'its rows' do
          subject(:rows) { country.rows }

          it 'has a header row' do
            rows.should include ['Average for year to', 'Sterling value of currency unit - £', 'Currency units per £1']
          end

          it { should have(59).rows }
        end
      end

      context 'CIS Russia' do
        let(:country_name) { 'cis_russia' }

        it 'has extra markup at the bottom' do
          country.extra_markup.should include('The CIS rate applies to states in the Russian Rouble zone.')
        end

        describe 'its rows' do
          subject(:rows) { country.rows }

          it 'has a header row' do
            rows.should include ['Average for year to', 'Sterling value of currency unit - £', 'Currency units per £1']
          end

          it { should have(29).rows }
        end
      end

      context 'Burma/Myanmar' do
        let(:country_name) { 'burma-myanmar' }

        describe 'its rows' do
          subject(:rows) { country.rows }

          it 'has rejected rows it cannot parse' do
            rows.should have(46).rows
          end
        end
      end

      context 'Romania' do
        let(:country_name) { 'romania' }

        describe 'its rows' do
          subject(:rows) { country.rows }

          it 'has dealt with its breaking case rows' do
            rows.should have(54).rows
          end
        end

      end
    end
  end
end
