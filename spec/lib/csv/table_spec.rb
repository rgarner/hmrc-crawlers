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

      context 'when a table with two rows that might be a header' do
        let(:html) do
          <<-HTML
          <table width="98%" border="0" cellpadding="1" class="table-border">
            <tr>
              <th scope="col"><p>Average for year to</p></th>
              <th scope="col"><p>Sterling value of currency unit - £</p></th>
            </tr>
            <tr>
              <th scope="col"><p>Sterling value of currency unit - £</p></th>
              <td>31.03.14</td>
            </tr>
          </table>
          HTML
        end
        it 'fails' do
          expect { Csv::Table.from_html(Nokogiri::HTML.fragment(html).at_css('table')).header }.to \
            raise_error(ArgumentError, /table has more than one header/)
        end
      end
    end

    context 'when the input is valid' do
      subject(:table) { Csv::Table.from_html(Nokogiri::HTML.fragment(html).at_css('table')) }

      context 'nil case' do
        let(:html) { nil }

        it 'nils all properties' do
          table.caption.should be_nil
          table.header.should be_nil
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
          table.header.should == [
            'Average for year to', 'Sterling value of currency unit - £', 'Currency units per £1'
          ]
        end

        it 'has two rows' do
          table.should have(2).rows
        end

        describe 'the first row' do
          subject(:row) { table.rows.first }

          its(:to_a) { should == ['31.03.14', '0.0079', '126.062557'] }
        end
      end

      context 'no rows' do
        let(:html) do
          <<-HTML
            <table width="98%" border="0" cellpadding="1" class="table-border">
            </table>
          HTML
        end

        its(:header)  { should be_nil }
        its(:caption) { should be_nil }

        it { should have(0).rows }
      end
    end

  end
end
