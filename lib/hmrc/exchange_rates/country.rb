require 'csv'
require 'csv/table'
require 'hmrc/exchange_rates/row'
require 'hmrc/exchange_rates/country/document'
require 'active_support/core_ext/string/inflections'

module Hmrc
  module ExchangeRates
    class Country
      attr_reader :doc, :original_url

      def initialize(doc, original_url = 'http://example.com')
        raise ArgumentError, 'Country.new requires an HTML document' \
          unless doc.kind_of?(Nokogiri::HTML::Document)

        @doc          = doc
        @original_url = original_url
      end

      def basename
        File.basename(original_url, '.htm')
      end

      def document
        @_document ||= Hmrc::ExchangeRates::Country::Document.new(self)
      end

      def table
        @_table ||= Csv::Table.from_html(table_node)
      end

      def table_node
        doc.at_css('#centre_col table table') || doc.at_css('#centre_col table')
      end

      def name
        @_name ||= ['title', '#centre_col h1'].map do |possible_title|
          text = doc.at_css(possible_title)
          text && (/exchange rates:\s*(?<parsed_name>.*)/m =~ text)
          parsed_name
        end.compact.first
      end

      def currency
        @_currency ||= begin
          # Assumes "-" is only used in euro dates
          /:\s+(?<currency_name>[^-]*)?/m =~ table.caption
          currency_name.strip.titleize
        end
      end

      def euro_date
        @_euro_date ||= begin
          /.*- Euro from\s+(?<text_euro_date>.*)$/m =~ table.caption
          Date.strptime(text_euro_date, '%d.%m.%y') if text_euro_date
        end
      end

      def issued
        @_issued ||= begin
          iso8601 = doc.at_xpath('//meta[@name="DCTERMS.issued"]')['content']
          iso8601 && Date.strptime(iso8601, '%Y-%m-%d')
        end
      end

      def extra_markup
        doc.xpath('//div[@id="centre_col"]//table//ul').to_html
      end

      def transformed_rows
        table.rows.reject { |r| r[0].strip.gsub("\u00A0", '') == '' }.map do |row|
          Hmrc::ExchangeRates::Row.new(row, self)
        end
      end

      def rows
        [table.header].concat(transformed_rows.map(&:to_a))
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
