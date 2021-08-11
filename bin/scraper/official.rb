#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class MemberList
  class Member
    def name
      Name.new(full: full_name, suffixes: %w[MP QC CBE CMG]).short
    end

    def position
      noko.css('.app-person__roles a').map(&:text).map(&:tidy)
    end

    private

    def full_name
      noko.css('.app-person-link__name').text.tidy
    end
  end

  class Members
    def member_container
      noko.css('#cabinet .person')
    end
  end
end

file = Pathname.new 'html/official.html'
puts EveryPoliticianScraper::FileData.new(file).csv
