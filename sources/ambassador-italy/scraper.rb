#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

# there's a hidden [update] on the last entry
class RemoveReferences < Scraped::Response::Decorator
  def body
    Nokogiri::HTML(super).tap do |doc|
      doc.css('sup').remove
    end.to_s
  end
end

class OfficeholderList < OfficeholderListBase
  decorator RemoveReferences
  decorator WikidataIdsDecorator::Links

  def holder_entries
    noko.xpath("//h3[.//span[contains(.,'Ambassador')]][last()]//following-sibling::ul[2]//li[a]")
  end

  class Officeholder < OfficeholderNonTableBase
    def name_node
      noko.css('a').last
    end

    def raw_combo_date
      noko.text.split(':').first
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url, klass: OfficeholderList).csv
