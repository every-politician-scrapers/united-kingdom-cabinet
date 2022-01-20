// wd create-entity create-office.js "Minister for X"
const fs = require('fs');
let rawmeta = fs.readFileSync('meta.json');
let meta = JSON.parse(rawmeta);

module.exports = (label) => {
  return {
    type: 'item',
    labels: {
      en: label,
    },
    descriptions: {
      en: "United Kingdom government position"
    },
    claims: {
      P31:   { value: 'Q294414' }, // instance of: public office
      P17:   { value: meta.country ? meta.country.id : meta.jurisdiction.id },
      P1001: { value: meta.jurisdiction.id },
    }
  }
}
