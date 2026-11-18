# <img src="bikebook.svg" alt="Bike Book logo" height="32"> [Bike Book](https://bikeindex.org/bikebook)

Compare bikes, e-bikes and e-Personal Mobility Devices (aka EPAMD).

Use the viewer at [bikeindex.org/bikebook](https://bikeindex.org/bikebook) to view the models.

This repository contains the data that is used to render that.

Please submit any fixes that you have!

## Technical info

This repository is a flat file database. The data is stored in JSON files.

**A file is at `<maker>/<year>/<slug>.json`, and its `id` repeats that path behind a type prefix** — `m/trek/2026/fuel_plus_mx_9_9_x0_axs_gen_2` is [vehicle_models/trek/2026/fuel_plus_mx_9_9_x0_axs_gen_2.json](vehicle_models/trek/2026/fuel_plus_mx_9_9_x0_axs_gen_2.json)

The manifest lists all the files, the catalog is published by [bikebook_ci](https://github.com/bikeindex/bikebook_ci) (which also is where the tests are).

---

© Bike Index and Bike Book contributors.

Read about the license and attribution at [bikeindex.org/bikebook/license](https://bikeindex.org/bikebook/license).

The data in this repository is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.

Product descriptions (the `description` of vehicle models and components) and photos (`stock_photo`, `geometry_photo`) belong to their manufacturers and aren't covered by CC BY-SA. They're included to identify the products, and we'll remove any on request: email licensing@bikeindex.org.

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png"/></a>

The data is provided as is, without warranties of any kind. E-vehicle classification, certification and legality information is general guidance, not legal advice: laws vary by country, state, city and campus and change over time, so check local rules and the manufacturer's documentation before relying on them.
