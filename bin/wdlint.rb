#!/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'json'
require 'pry'

class WikidataDate
  def initialize(date, precision)
    @date = date
    @precision = precision
  end

  def to_s
    return date if precision.to_s.empty?
    return date[0...4] if precision == 9
    return date[0...7] if precision == 10
    return date[0...10] if precision == 11
    binding.pry
  end

  private

  attr_reader :date, :precision
end

class CSV::Row
  def method_missing(m, *args, &block)
    return fetch(m) if header?(m)

    return item_str if m == :id

    if datefield = m[/(.*)_date$/, 1]
      return WikidataDate.new(*values_at(datefield.to_sym, "#{datefield}precision".to_sym)).to_s
    end

    if field = m[/(.*)_str$/, 1]
      id, label = values_at(field.to_sym, "#{field}label".to_sym)
      return id.to_s.empty? ? "" : "#{label} (#{id})"
    end

    super
  end
end

cabinets = CSV.table('wikidata/results/all-cabinets.csv')
warnings = {}

by_id = cabinets.group_by(&:id)

#---------------------------
# No ordinal (but others do)
#---------------------------
warnings[:no_ordinal] = cabinets.reject(&:ordinal).map(&:id) if cabinets.any?(&:ordinal)

#------------------
# No inception date
#------------------
no_inception = cabinets.reject(&:inception)
warnings[:no_inception] = no_inception.map { |row| [row.id, row.starttime_date] }.to_h

#------------------
# No abolition date
#------------------
no_abolished = cabinets.reject(&:abolished)
warnings[:no_abolished] = no_abolished.map { |row| [row.id, row.endtime_date] }.to_h

#-----------------------------
# More than one inception date
#-----------------------------
multiple_inception = by_id.select { |id, rows| rows.map { |row| row[:inception] }.uniq.count > 1 }
warnings[:multiple_inception] = multiple_inception.map { |id, rows| [id, rows.map(&:inception_date)] }.to_h

#-----------------------------
# More than one abolished date
#-----------------------------
multiple_abolished = by_id.select { |id, rows| rows.map { |row| row[:abolished] }.uniq.count > 1 }
warnings[:multiple_abolished] = multiple_abolished.map { |id, rows| [id, rows.map(&:abolished_date)] }.to_h

#-------------------
# start != inception
#-------------------
mmi = cabinets.select { |row| row.starttime && row.inception && row.inception_date != row.starttime_date }
warnings[:mismatched_inception] = mmi.map { |row| [row.id, [row.inception_date, row.starttime_date]] }.to_h

#-----------------
# end != abolished
#-----------------
mma = cabinets.select { |row| row.endtime && row.abolished && row.abolished_date != row.endtime_date }
warnings[:mismatched_abolished] = mma.map { |row| [row.id, [row.abolished_date, row.endtime_date]] }.to_h


#------------
# No replaces
#------------
no_replaces = cabinets.reject(&:replaces)
warnings[:no_replaces] = no_replaces.map { |row| [row.id, row.follows_str] }.to_h

#-----------------------
# More than one replaces
#-----------------------
multiple_replaces = by_id.select { |id, rows| rows.map(&:replaces).uniq.count > 1 }
warnings[:multiple_replaces] = multiple_replaces.map { |id, rows| [id, rows.map(&:replaces_str)] }.to_h

#---------------
# No replaced_by
#---------------
no_replacedby = cabinets.reject(&:replacedby)
warnings[:no_replacedby] = no_replacedby.map { |row| [row.id, row.followedby_str] }.to_h

#--------------------------
# More than one replaced_by
#--------------------------
multiple_replacedby = by_id.select { |id, rows| rows.map(&:replacedby).uniq.count > 1 }
warnings[:multiple_replacedby] = multiple_replacedby.map { |id, rows| [id, rows.map(&:replacedby_str)] }.to_h

#--------------------
# replaces != follows
#--------------------
mmr = cabinets.select { |row| row.replaces && row.follows && row.replaces != row.follows }
warnings[:mismatched_replaces] = mmr.map { |row| [row.id, [row.replaces_str, row.follows_str]] }.to_h

#-------------------------
# replacedby != followedby
#-------------------------
mmrb = cabinets.select { |row| row.replacedby && row.followedby && row.replacedby != row.followedby }
warnings[:mismatched_replacedby] = mmrb.map { |row| [row.id, [row.replacedby_str, row.followedby_str]] }.to_h

puts JSON.pretty_generate(warnings)
