require 'nokogiri'

module Csv
  class Table
    EMPTY = Nokogiri::HTML.fragment('<table />')

    def initialize(node)
      @table = node || EMPTY
    end

    def header
      header_rows = @table.xpath('tr[th]')

      raise ArgumentError, 'table has more than one header row' if header_rows.length > 1
      return nil if header_rows.empty?

      header_rows.first.xpath('th').map(&:content)
    end

    def rows
      @table.xpath('tr[td]').map do |tr|
        tr.css('td').map { |td| td.content }
      end
    end

    def caption
      caption_node = @table.at_css('caption')
      caption_node && caption_node.text.strip
    end

    def self.from_html(node)
      raise ArgumentError, 'expects a node' unless node.nil? || node.is_a?(Nokogiri::XML::Node)
      Table.new(node)
    end
  end
end
