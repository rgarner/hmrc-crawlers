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

    HEADER = ['Type', 'From date', 'To date', 'Sterling value of currency unit - £', 'Currency units per £1', 'Currency']

    def header
      HEADER
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
