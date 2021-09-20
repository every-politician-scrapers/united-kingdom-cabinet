const fs = require('fs');
let rawmeta = fs.readFileSync('meta.json');
let meta = JSON.parse(rawmeta);

module.exports = function () {
  return `SELECT DISTINCT ?item ?itemLabel ?start ?end ?predecessor ?successor
  WHERE {
    ?item wdt:P31 wd:Q2500378.
    OPTIONAL { ?item wdt:P580 | wdt:P571 ?start }
    OPTIONAL { ?item wdt:P582 | wdt:P576 ?end }
    OPTIONAL { ?item wdt:P1365 | wdt:P155 ?predecessor }
    OPTIONAL { ?item wdt:P1366 | wdt:P156 ?successor }
    SERVICE wikibase:label { bd:serviceParam wikibase:language "en". } 
  }
  ORDER BY ?itemLabel ?start`
}
