#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

require 'open-uri/cached'

# There are lots of blank images messing up the layout,
# so just rmeove any image link
class RemoveImageLinks < Scraped::Response::Decorator
  def body
    Nokogiri::HTML(super).tap do |doc|
      doc.xpath('.//a[img]').remove
    end.to_s
  end
end

class OfficeholderList < OfficeholderListBase
  decorator RemoveImageLinks
  decorator RemoveReferences
  decorator UnspanAllTables
  decorator WikidataIdsDecorator::Links

  def header_column
    'Incumbent'
  end

  class Officeholder < OfficeholderBase
    def columns
      %w[dates name notes].freeze
    end

    def combo_date
      rstart, rend = raw_combo_dates
      # Add missing month+year if in format "8-20 May 2019"
      return [rend.sub(/^\d+/, rstart[0..2]).tidy, rend] if rstart[/^\d{1,2}$/]
      # Add missing year if in format "April 8 - May 20 2019"
      return ["#{rstart}, #{rend[-4..]}", rend] unless rstart[/\d{4}$/]

      [rstart, rend]
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url, klass: OfficeholderList).csv
