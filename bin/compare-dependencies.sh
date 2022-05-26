#!/bin/bash

bundle exec ruby bin/scraper/dependencies-wikipedia.rb > data/dependencies-wikipedia.csv
# No comparison yet: scraping just to track diffs
