#!/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'pry'
require 'scraped'
require 'wikidata_ids_decorator'

require 'open-uri/cached'

class RemoveReferences < Scraped::Response::Decorator
  def body
    Nokogiri::HTML(super).tap do |doc|
      doc.css('sup.reference').remove
    end.to_s
  end
end

class MinistersList < Scraped::HTML
  decorator RemoveReferences
  decorator WikidataIdsDecorator::Links

  field :ministers do
    member_entries.map { |ul| fragment(ul => Officeholder).to_h }
  end

  private

  def member_entries
    table.flat_map { |table| table.xpath('.//tr[td]') }
  end

  def table
    noko.xpath('//table[.//th[contains(.,"Position")]]').drop(1)
  end
end

class Officeholder < Scraped::HTML
  field :location do
    location_link.attr('wikidata')
  end

  field :locationLabel do
    location_link.text.tidy
  end

  field :position do
    position_link.attr('wikidata')
  end

  field :positionLabel do
    position_link.text.tidy
  end

  field :person do
    name_link.attr('wikidata')
  end

  field :personLabel do
    name_link.text.tidy
  end

  private

  def tds
    noko.css('td')
  end

  def location_link
    noko.xpath('.//th[1]//a[@href]')
  end

  def position_link
    tds[0].xpath('.//a[@href]').first
  end

  def name_link
    tds[1].xpath('.//a[@href]').first
  end
end

url = 'https://en.wikipedia.org/wiki/List_of_current_heads_of_government_in_the_United_Kingdom_and_dependencies'
data = MinistersList.new(response: Scraped::Request.new(url: url).response).ministers

header = data.first.keys.to_csv
rows = data.map { |row| row.values.to_csv }
abort 'No results' if rows.count.zero?

puts header + rows.join
