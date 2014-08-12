require 'spec_helper'
require 'csv/table'

describe Csv::Table do
  describe '#from_html' do
    context 'when the input is bad' do
      context 'when not even a node' do
        it 'fails' do
          expect { Csv::Table.from_html(1) }.to raise_error(ArgumentError, /expects a node/)
        end
      end
    end

    context 'when the input is valid' do
      subject(:table) { Csv::Table.from_html(Nokogiri::HTML.fragment(html).at_css('table')) }

      context 'nil case' do
        let(:html) { nil }

        it 'nils all properties' do
          table.caption.should be_nil
          table.should have(0).rows
        end
      end

      context 'happy path' do
        let(:html) do
          <<-HTML
          <table width="98%" border="0" cellpadding="1" class="table-border">
            <caption>
            Unit of currency: ALGERIAN DINAR
            </caption>
            <tr>
              <th scope="col"><p>Average for year to</p></th>
              <th scope="col"><p>Sterling value of currency unit - £</p></th>
              <th scope="col"><p>Currency units per £1</p></th>
            </tr>
            <tr>
              <td>31.03.14</td>
              <td>0.0079</td>
              <td>126.062557</td>
            </tr>
            <tr>
              <td>31.12.13</td>
              <td>0.008</td>
              <td>124.489188</td>
            </tr>
          </table>
          HTML
        end

        it { should be_a(Csv::Table) }

        it 'has a caption with no whitespace' do
          table.caption.should == 'Unit of currency: ALGERIAN DINAR'
        end

        it 'has a header' do
          table.header.should == Csv::Table::HEADER
        end

        it 'has only the data in rows, no header or caption' do
          table.rows.should == [
            ['31.03.14', '0.0079', '126.062557'],
            ['31.12.13', '0.008', '124.489188']
          ]
        end
      end

      context 'no rows' do
        let(:html) do
          <<-HTML
            <table width="98%" border="0" cellpadding="1" class="table-border">
            </table>
          HTML
        end

        its(:header)  { should == Csv::Table::HEADER }
        its(:caption) { should be_nil }

        it { should have(0).rows }
      end

      context 'a table with a tbody found within another table, broken header and caption semantics' do
        let(:html) do
          <<-HTML
            <table width="589" border="0" cellpadding="0">
              <tbody><tr>
                <td colspan="3">Unit of currency: ROUBLE (Official/Floating)</td>
              </tr>
              <tr>
                <td>&nbsp;</td>
                <td> <p align="center">Sterling value of currency unit </p>
                  <p align="center">£</p></td>
                <td> <p align="center">Currency units per £ </p>
                  <p align="center">R</p></td>
              </tr>
              <tr>
                <td>31.03.14</td>
                <td>0.0195</td>
                <td>51.232159</td>
              </tr>
              </tr>
            </tbody>
          </table>
          HTML
        end

        it 'gets the caption from the "wrong" place' do
          table.caption.should == 'Unit of currency: ROUBLE (Official/Floating)'
        end

        it 'ignores what is there and constructs a header' do
          table.header.should == Csv::Table::HEADER
        end

        it 'only has the data in rows, not the pseudo-caption or pseudo-header' do
          table.rows.should == [['31.03.14', '0.0195', '51.232159']]
        end
      end

      context 'a table with no tbody found within another table, broken header and caption semantics' do
        let(:html) {
          <<-HTML
<table width="589" border="0" cellpadding="0">
          <tr>
            <td colspan="3">Unit of currency: FRENCH FRANC - <strong>Euro from
              1.1.02</strong> </td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td> <p align="center">Sterling value of currency unit </p>
              <p align="center">&pound;</p></td>
            <td> <p align="center">Currency units per &pound; </p>
              <p align="center">F</p></td>
          </tr>
          <tr>
            <td>31.03.14</td>
            <td>0.8436</td>
            <td>1.185417</td>
          </tr>
          HTML
        }

        it 'gets the caption from the "wrong" place' do
          table.caption.should == "Unit of currency: FRENCH FRANC - Euro from\n              1.1.02"
        end

        it 'ignores what is there and constructs a header' do
          table.header.should == Csv::Table::HEADER
        end

        it 'only has the data in rows, not the pseudo-caption or pseudo-header' do
          table.rows.should == [['31.03.14', '0.8436', '1.185417']]
        end
      end

    end

  end
end
