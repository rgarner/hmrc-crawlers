require 'nokogiri'

module Csv
  class Table
    EMPTY = Nokogiri::HTML.fragment('<table />')

    def initialize(node)
      # We've been given a table node. Everything will be relative to
      # it or a tbody, if one exists. Root the table there.
      @table = case
               when node.nil? then EMPTY
               when node.at_xpath('tbody') then node.at_xpath('tbody')
               else node
               end
    end

    def header
      header_row = @table.at_xpath('tr[th]')
      if header_row
        header_row.xpath('th').map(&:content)
      else
        header_row = @table.at_xpath('tr[td[p[@align="center"]]]')
        header_row && ['Average for year to', 'Sterling value of currency unit - £', 'Currency units per £1']
      end
    end

    def caption
      caption_node =
        @table.at_css('caption') ||
        @table.at_xpath('tr/td[@colspan="3"]')
      caption_node && caption_node.text.strip
    end

    def rows
      data_tr_nodes.map do |tr|
        tr.css('td').map { |td| td.content }
      end
    end

    ##
    # Only data rows - exclude pseudo-caption and pseudo-headers
    def data_tr_nodes
      @table.xpath('tr[td and not(td/p[@align]) and not(td[@colspan])]')
    end

    def self.from_html(node)
      raise ArgumentError, 'expects a node' unless node.nil? || node.is_a?(Nokogiri::XML::Node)
      Table.new(node)
    end
  end
end
