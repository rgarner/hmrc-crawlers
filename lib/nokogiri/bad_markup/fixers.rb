module Nokogiri
  module BadMarkup
    module Fixers
      def normalise_single_item_lists
        return self unless (first_ul = at_xpath('ul'))

        xpath('ul[count(li) = 1]').each do |ul|
          next if ul == first_ul

          ul.unlink
          ul.xpath('li').each do |li|
            li.parent = first_ul
          end
        end

        self
      end
    end
  end
end

Nokogiri::XML::Node.class_eval do
  include Nokogiri::BadMarkup::Fixers
end
