# <img src="bikebook.svg" alt="Bike Book logo" height="32"> [Bike Book](https://bikeindex.org/bikebook)

Compare bikes, e-bikes and e-Personal Mobility Devices (aka EPAMD). Check out the viewer at [bikeindex.org/bikebook](https://bikeindex.org/bikebook).

## What?

Bike Index decided to create an open source repository of all the bike (and e-bike, trike, EPAMD, etc, hereafter just referred to as "bike") data.

Bikes are surprising complex and have a myriad of conflicting options. So we needed a data format - explore the current JSON Schema at [bikeindex.org/bikebook/schema_viewer](https://bikeindex.org/bikebook/schema_viewer), which looks something like this:



The schema viewer helps make sense of what things are captured by including comments and showing the number of matching bikes, and including sample bike IDs (which link to the [model viewer](https://bikeindex.org/bikebook)).

---

Some things that missing or improvements to make in upcoming schema versions:

- Better handling of markets
- Better handling of tandems
- Better handling of non-bike things
- Capturing more measurements of components and interfaces, so it can be used as a reference for repair (e.g. replacement bearing sizes)


---

This repository contains the data that is used to render that.


## Technical info

This repository is a flat file database. The data is stored in JSON files.

The 2026 `Fuel+ MX 9.9 X0 AXS Gen 2` by Trek has this id: `m/trek/2026/fuel-plus-mx-9-9-x0-axs-gen-2`

Which is in this repository at [vehicle_models/trek/2026/fuel-plus-mx-9-9-x0-axs-gen-2.json](vehicle_models/trek/2026/fuel-plus-mx-9-9-x0-axs-gen-2.json)

**The model IDs are at `<maker>/<year>/<model name>.json`** and the files are at that path in `vehicle_models/`

`<maker>` and `<model>` are converted to slugs following this path:

1. Drops parentheticals and turn `%20` into a space
2. Decodes HTML entities like `&amp;`
3. Deletes apostrophes, so "Bob’s" becomes bobs, not bob-s.
4. Lowercases, then swaps accented letters for plain ones (ß → ss, æ → ae).
5. Turns & into "and" and + into "plus".
6. Joins the remaining runs of letters and digits with hyphens.

```js
// I18n::Backend::Transliterator::HashTransliterator::DEFAULT_APPROXIMATIONS, lower-case entries only (the
// text is downcased first). Any other non-ASCII character becomes "?" in Rails, so it separates words here too.
const APPROXIMATIONS = Object.fromEntries(
  ("àa áa âa ãa äa åa æae çc èe ée êe ëe ìi íi îi ïi ðd ñn òo óo ôo õo öo øo ùu úu ûu üu ýy þth ßss ÿy " +
    "āa ăa ąa ćc ĉc ċc čc ďd đd ēe ĕe ėe ęe ěe ĝg ğg ġg ģg ĥh ħh ĩi īi ĭi įi ıi ĳij ĵj ķk ĸk ĺl ļl ľl ŀl łl " +
    "ńn ņn ňn ŉ'n ŋng ōo ŏo őo œoe ŕr ŗr řr śs ŝs şs šs ţt ťt ŧt ũu ūu ŭu ůu űu ųu ŵw ŷy źz żz žz ǫo ǭo")
    .split(" ")
    .map((pair) => [pair[0], pair.slice(1)])
)
APPROXIMATIONS["×"] = "x"

// CGI.unescapeHTML: the five named entities and numeric ones
const ENTITIES = { amp: "&", quot: '"', apos: "'", lt: "<", gt: ">" }
const unescapeHTML = (text) =>
  text.replace(/&(amp|quot|apos|lt|gt|#\d+|#x[0-9a-f]+);/gi, (match, entity) => {
    if (entity[0] !== "#") return ENTITIES[entity.toLowerCase()] ?? match
    const code = entity[1].toLowerCase() === "x" ? parseInt(entity.slice(2), 16) : parseInt(entity.slice(1), 10)
    return code <= 0x10ffff ? String.fromCodePoint(code) : match
  })

const transliterate = (text) =>
  Array.from(text, (character) =>
    character.charCodeAt(0) < 128 ? character : APPROXIMATIONS[character] ?? "?"
  ).join("")

export function slugify(string) {
  const text = String(string ?? "")
    .replace(/\([^)]*\)/g, "") // parentheticals are dropped
    .replaceAll("%20", " ")
  const words = transliterate(unescapeHTML(text).replace(/['’‘`´]/g, "").toLowerCase())
    .replaceAll("&", " and ")
    .replaceAll("+", " plus ")
    .match(/[a-z0-9]+/g)
  return (words ?? []).join("-")
}
```

The manifest lists all the files, the catalog is published by [bikebook_ci](https://github.com/bikeindex/bikebook_ci) (which also is where the tests are).


---

## Contributing

Please submit any fixes that you have! See [CONTRIBUTING](CONTRIBUTING.md): contributors sign our [Contributor License Agreement](https://cla-assistant.io/bikeindex/bikebook) before their first pull request is merged.

## Versioning

schema_version is semantic:
- Major versions remove, rename or retype a field or remove an enum value
- Minor ones add an optional field or an enum value
- Patches changes only descriptions.

The published catalog's format is versioned apart from it, one integer raised whenever the layout of its files changes.

---

© Bike Index and Bike Book contributors.

Read about the license and attribution at [bikeindex.org/bikebook/license](https://bikeindex.org/bikebook/license).

The data in this repository is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.

Product descriptions (the `description` of vehicle models and components) and photos (`stock_photo`, `geometry_photo`) belong to their manufacturers and aren't covered by CC BY-SA. They're included to identify the products, and we'll remove any on request: email licensing@bikeindex.org.

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png"/></a>

The data is provided as is, without warranties of any kind. E-vehicle classification, certification and legality information is general guidance, not legal advice: laws vary by country, state, city and campus and change over time, so check local rules and the manufacturer's documentation before relying on them.
