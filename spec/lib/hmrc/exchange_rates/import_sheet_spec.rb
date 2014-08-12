require 'spec_helper'
require 'hmrc/exchange_rates/import_sheet'
require 'hmrc/exchange_rates/country'
require 'json'

ImportSheet = Hmrc::ExchangeRates::ImportSheet

describe ImportSheet do
  subject(:sheet) { ImportSheet.new }
  it 'has a header' do
    sheet.header.should == [
      'old_url',
      'title',
      'summary',
      'body',
      'organisation',
      'first_published',
      'publication_type',
      'json_attachments'
    ]
  end

  it 'has no rows' do
    sheet.should have(0).rows
  end

  context 'when we add rows' do
    context 'happy path' do
      let(:url) { 'http://example.com/1' }
      let(:country) do
        Hmrc::ExchangeRates::Country.new(
          Nokogiri::HTML(File.read('spec/fixtures/exchange_rates/cis_russia.html')),
          'http://example.com/cis-russia.htm'
        )
      end

      before do
        sheet.add_country(url, country)
      end

      it { should have(1).row }
      describe 'the row' do
        subject(:row) { sheet.rows.first }
        its([0]) { should == url }
        its([1]) { should == 'Foreign Exchange Rates: CIS: Russia' }
        its([2]) { should == 'Historical exchange rates for CIS: Russia' }
        its([3]) { should include '*  CIS: the official rate ceased to be quoted from 31 March 1996.' }
        its([4]) { should == 'hm-revenue-customs' }
        its([5]) { should == '08-Apr-2014' }
        its([6]) { should == '' }
        describe 'the JSON attachments' do
          subject { JSON.parse(row[7], symbolize_names: true) }

          its([:title]) { should == country.document.title }
          its([:url])   { should ==
            'https://raw.githubusercontent.com/rgarner/hmrc-crawlers/master/results/cis-russia.csv'
          }
        end
      end

      describe '#save!' do
        let(:test_csv) { 'spec/fixtures/_import.csv' }

        before { sheet.save!(test_csv) }
        after  { File.delete(test_csv) }

        describe 'the resulting lines' do
          subject(:lines) { File.read(test_csv).split("\n") }

          it 'has a header' do
            lines.should include(ImportSheet::HEADER.join(','))
          end

          it 'has some data' do
            lines[1].should include('Foreign Exchange Rates: CIS: Russia,')
          end
        end

      end
    end
  end
end
