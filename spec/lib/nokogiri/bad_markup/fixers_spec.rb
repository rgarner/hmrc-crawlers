require 'spec_helper'
require 'nokogiri'
require 'nokogiri/bad_markup/fixers'

describe 'the fixers' do
  describe '#normalise_single_item_lists' do
    let(:html) do
      <<-HTML
        <ul><li>Item one</li></ul>
        <ul><li>Item two</li></ul>
        <ul><li>Item three</li></ul>
      HTML
    end

    let(:fragment) { Nokogiri::HTML.fragment(html) }

    subject(:result) { fragment.normalise_single_item_lists }

    it 'returns something chainable' do
      result.should be_a(Nokogiri::XML::Node)
    end

    it 'has collapsed the single-item lists' do
      result.xpath('ul').should    have(1).list
      result.xpath('ul/li').should have(3).list_items
    end
  end
end
