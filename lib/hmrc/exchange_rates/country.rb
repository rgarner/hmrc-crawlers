require 'csv/table'
require 'hmrc/exchange_rates/row'
require 'csv'
require 'active_support/core_ext/string/inflections'

module Hmrc
  module ExchangeRates
    class Country
      attr_reader :doc

      def initialize(doc)
        raise ArgumentError, 'Country.new requires an HTML document' \
          unless doc.kind_of?(Nokogiri::HTML::Document)

        @doc = doc
      end

      def table
        @_table ||= Csv::Table.from_html(table_node)
      end

      def table_node
        doc.at_css('#centre_col table table') || doc.at_css('#centre_col table')
      end

      def name
        @_name ||= begin
          title_text = doc.at_css('title').text
          /exchange rates:\s*(?<parsed_name>.*)/m =~ title_text
          parsed_name
        end
      end

      def currency
        @_currency ||= begin
          /:\s+(?<currency_name>.*)$/ =~ table.caption
          currency_name.titleize
        end
      end

      def extra_markup
        doc.xpath('//div[@id="centre_col"]//table//ul').to_html
      end

      def transformed_rows
        table.rows.reject { |r| r[0].strip.gsub("\u00A0", '') == '' }.map do |row|
          Hmrc::ExchangeRates::Row.new(row).to_a
        end
      end

      def rows
        [table.header].concat(transformed_rows)
      end

      def to_csv
        CSV.generate do |csv|
          rows.each do |row|
            csv << row
          end
        end
      end
    end
  end
end
