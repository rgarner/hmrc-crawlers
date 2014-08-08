require 'nokogiri'

module Csv
  class Table
    EMPTY = Nokogiri::HTML.fragment('<table />')

    def initialize(node)
      @table = node || EMPTY
    end

    def header
      header_row = @table.at_xpath('tr[th]')
      if header_row
        header_row.xpath('th').map(&:content)
      else
        header_row = @table.at_xpath('tbody/tr[td[p[@align="center"]]]')
        header_row && ['Average for year to', 'Sterling value of currency unit - £', 'Currency units per £1']
      end
    end

    def caption
      caption_node =
        @table.at_css('caption') ||
        @table.at_xpath('tbody/tr/td[@colspan="3"]')
      caption_node && caption_node.text.strip
    end

    def rows
      @table.xpath('tr[td]').map do |tr|
        tr.css('td').map { |td| td.content }
      end
    end

    def self.from_html(node)
      raise ArgumentError, 'expects a node' unless node.nil? || node.is_a?(Nokogiri::XML::Node)
      Table.new(node)
    end
  end
end
