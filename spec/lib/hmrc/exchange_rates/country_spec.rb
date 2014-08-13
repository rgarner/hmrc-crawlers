# encoding: utf-8

require 'spec_helper'

require 'hmrc/exchange_rates/country'
require 'nokogiri'

Country = Hmrc::ExchangeRates::Country

describe Country do
  describe '.parse' do
    context 'when the input is bad' do
      it 'requires a Nokogiri element' do
        expect { Country.new(1) }.to raise_error(
                                         ArgumentError, /requires an HTML document/)
      end
    end

    context 'when the input is good' do
      subject(:country) do
        Country.new(
          Nokogiri::HTML(File.read("spec/fixtures/exchange_rates/#{country_name}.html")),
          "http://example.com/#{country_name}.htm"
        )
      end

      context 'Algeria' do
        let(:country_name) { 'algeria' }

        its(:name)            { should == 'Algeria' }
        its(:currency)        { should == 'Algerian Dinar' }
        its(:issued)          { should == Date.new(2014, 4, 8) }
        its(:original_url)    { should == 'http://example.com/algeria.htm'}
        its(:basename)        { should == 'algeria' }

        describe 'its rows' do
          subject (:rows) { country.rows }

          it { should be_an(Array) }

          it { should have(53).rows }

          it 'has a header row' do
            rows.should include [
              'Type', 'From date', 'To date', 'Sterling value of currency unit - £', 'Currency units per £1', 'Currency'
            ]
          end

          it 'has value rows that transform the date' do
            rows.should include ['Average', '2013-03-31', '2014-03-31', '0.0079', '126.062557', 'Algerian Dinar']
          end

          it 'has value rows that transform last-century values' do
            FIRST_LAST_CENTURY_ROW = 30
            rows[FIRST_LAST_CENTURY_ROW].should == ['Average', '1998-12-30', '1999-12-30', '0.0093322408', '107.1554', 'Algerian Dinar']
          end

          it 'has date ranges that transform' do
            FIRST_RANGE_ROW = 39
            rows[FIRST_RANGE_ROW].should == ['Average', '1994-04-15', '1995-03-31', '0.0156146', '64.0424', 'Algerian Dinar']
          end
        end

        describe 'its document' do
          subject(:document) { country.document }

          it { should be_a(Hmrc::ExchangeRates::Country::Document) }
        end


        describe 'its to_csv' do
          subject(:to_csv) { country.to_csv }

          it 'has a header row' do
            to_csv.should include(Csv::Table::HEADER.join(','))
          end

          it 'has value rows that transform the date' do
            to_csv.should include "Average,1998-12-30,1999-12-30,0.0093322408,107.1554,Algerian Dinar\n"
          end
        end
      end

      context 'France' do
        let(:country_name) { 'france' }

        its(:issued) { should == Date.new(2014, 4, 8) }

        it 'finds the table within the table' do
          country.table_node['width'].should == '589'
        end

        describe 'its rows' do
          subject(:rows) { country.rows }

          it 'has a header row' do
            rows.should include Csv::Table::HEADER
          end

          it { should have(59).rows }
        end
      end

      context 'CIS Russia' do
        let(:country_name) { 'cis_russia' }

        its(:name)     { should == 'CIS: Russia' }
        its(:currency) { should == 'Rouble (Official/Floating)' }

        describe 'its rows' do
          subject(:rows) { country.rows }

          it 'has a header row' do
            rows.should include Csv::Table::HEADER
          end

          it { should have(29).rows }
        end
      end

      context 'Burma/Myanmar (blank rows)' do
        let(:country_name) { 'burma-myanmar' }

        describe 'its rows' do
          subject(:rows) { country.rows }

          it 'has rejected rows it cannot parse' do
            rows.should have(46).rows
          end
        end
      end

      context 'Romania (breaking slash dates)' do
        let(:country_name) { 'romania' }

        describe 'its rows' do
          subject(:rows) { country.rows }

          it 'has dealt with its breaking case rows' do
            rows.should have(54).rows
          end
        end

      end

      context 'Surinam (breaking no-day dates)' do
        let(:country_name) { 'surinam' }

        describe 'its rows' do
          subject(:rows) { country.rows }

          it 'has dealt with its breaking case rows' do
            rows.should have(55).rows
          end
        end
      end

      context 'Brazil (31st September!)' do
        let(:country_name) { 'brazil' }

        describe 'its rows' do
          subject(:rows) { country.rows }

          it 'has dealt with its breaking case rows' do
            rows.should have(57).rows
          end
        end
      end

      context 'when the title is broken' do
        context 'Brunei' do
          let(:country_name) { 'brunei' }
          its(:name) { should == 'Brunei' }
        end

        context 'Latvia' do
          let(:country_name) { 'latvia' }
          its(:name) { should == 'Latvia' }
        end
      end

      context 'When in the euro' do
        let(:euro_rows)     { rows.select { |row| row.date_range.to_date >= country.euro_date } }
        let(:pre_euro_rows) { rows.select { |row| row.date_range.to_date <  country.euro_date } }

        let(:rows) { country.transformed_rows }

        context 'Greece (normal)' do
          let(:country_name) { 'greece' }

          its(:name)      { should == 'Greece' }
          its(:currency)  { should == 'Greek Drachma' }
          its(:euro_date) { should == Date.new(2002, 1, 1)}

          it 'has a small number of Euro rows' do
            euro_rows.should have(6).items
          end

          it 'has a larger number of Drachma rows' do
            pre_euro_rows.should have(25).items
          end
        end

        context 'Austria (no usable unit of currency header)' do
          let(:country_name) { 'austria' }

          its(:name)      { should == 'Austria' }
          its(:currency)  { should == 'Austrian Schilling' }
          its(:euro_date) { should == Date.new(1999, 1, 1)}

          it 'has a smaller number of Euro rows' do
            euro_rows.should have(26).items
          end

          it 'has a larger number of Austrian Schilling rows' do
            pre_euro_rows.should have(38).items
          end
        end
      end
    end
  end
end
