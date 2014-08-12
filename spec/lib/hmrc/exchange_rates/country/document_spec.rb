require 'spec_helper'
require 'hmrc/exchange_rates/country/document'

describe Hmrc::ExchangeRates::Country::Document do
  context 'input is not a Country' do
    it 'fails' do
      expect { Hmrc::ExchangeRates::Country::Document.new('not a country') }.to raise_error(
        ArgumentError, /requires a country/)
    end
  end

  context 'input is a country' do
    subject(:doc) { Hmrc::ExchangeRates::Country::Document.new(country) }

    let(:country) do
      Hmrc::ExchangeRates::Country.parse(
        Nokogiri::HTML(
          File.read("spec/fixtures/exchange_rates/#{country_name}.html")
        )
      )
    end

    context 'Algeria' do
      let(:country_name) { 'algeria' }

      it 'has the country' do
        doc.country.should == country
      end

      describe 'the metadata' do
        its(:title)   { should == 'Foreign Exchange Rates: Algeria' }
        its(:summary) { should == 'Historical exchange rates for Algeria' }
      end

      describe 'the markdown' do
        subject { doc.body }

        it { should include('# Foreign Exchange Rates: Algeria') }
        it { should include('## Unit of currency: Algerian Dinar') }
      end
    end

    context 'CIS Russia' do
      let(:country_name) { 'cis_russia' }

      it 'has the country' do
        doc.country.should == country
      end

      describe 'the metadata' do
        its(:title) { should == 'Foreign Exchange Rates: CIS: Russia' }
      end

      describe 'the extra markdown' do
        subject(:extra_markdown) { doc.extra_markdown }

        it { should include '*  The CIS rate applies to states in the Russian Rouble zone.' }
      end

      describe 'the markdown' do
        subject(:markdown_lines) { doc.body.split("\n") }

        it { should include('# Foreign Exchange Rates: CIS: Russia') }
        it { should include('## Unit of currency: Rouble (Official/Floating)') }
        it 'normalises the rubbish in extra_markdown' do
          markdown_lines.should include '*  The CIS rate applies to states in the Russian Rouble zone.'
        end
      end
    end
  end
end
