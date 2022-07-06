#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class MemberList
  class Member
    def name
      Name.new(full: full_name, suffixes: %w[MP QC CBE CMG]).short
    end

    POSITION_MAP = {
      'Lord Chancellor and Secretary of State for Justice' =>  ['Lord Chancellor', 'Secretary of State for Justice']
    }

    def position
      raw_position.map { |posn| POSITION_MAP.fetch(posn, posn) }
    end

    private

    def full_name
      noko.css('.app-person-link__name').text.tidy
    end

    def raw_position
      noko.css('.app-person__roles a').map(&:text).map(&:tidy)
    end
  end

  class Members
    def member_container
      noko.css('#cabinet,#also-attends-cabinet').css('.person')
    end
  end
end

file = Pathname.new 'official.html'
puts EveryPoliticianScraper::FileData.new(file).csv
