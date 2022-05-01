#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class OfficeholderNonTable < OfficeholderListBase::OfficeholderBase
  def empty?
    false
  end

  def combo_date?
    true
  end

  def raw_combo_date
    raise 'need to define a raw_combo_date'
  end

  def name_node
    raise 'need to define a name_node'
  end
end


class OfficeholderList < OfficeholderListBase
  decorator RemoveReferences
  # decorator UnspanAllTables
  decorator WikidataIdsDecorator::Links

  def header_column
    'Ambassador'
  end

  # TODO: make this easier to override
  def holder_entries
    noko.xpath("//h3[.//span[contains(.,'#{header_column}')]][last()]//following-sibling::ul[2]//li[a]")
  end

  class Officeholder < OfficeholderNonTable
    # TODO: push up
    def raw_combo_date
      noko.text.tidy.split(':').first.split('[').first
    end

    def name_node
      noko.css('a').last
    end

    def item
      noko.css('a/@wikidata').map(&:text).last
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url, klass: OfficeholderList).csv
