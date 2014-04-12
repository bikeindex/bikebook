#![BikeBook.io](https://github.com/bikeindex/bikebook/blob/master/public/small_icon.png?raw=true) [BikeBook.io](http://bikebook.io)

Compare bikes!

Research bikes!

**Open source everything!**

## Technical

BikeBook.io is a single page web application that accesses default bike information through it's own RESTfull JSON API.

This repository contains the web application and also all of the of bike data. All the data is stored in flat files, BikeBook just reads the file you requested.

## How?

Simple.

Send a [query](https://en.wikipedia.org/wiki/Query_string) with field value pairs, get shit back.

There are three main requests you can make:

- Get a list of all the unique model names a manufacturer has produced
- Get a list of models from a manufacturer by year
- Get information about a bike

#### Get unique models

Send a query with a `manufacturer` to BikeBook.io/model_list

So for Heritage cycles, [BikeBook.io/model_list?manufacturer=Heritage cycles](http://bikebook.io/model_list?manufacturer=Heritage%20cycles)

#### Get models by year

Send a query with `manufacturer` to BikeBook.io

So for Cinelli, [BikeBook.io?manufacturer=Cinelli](http://bikebook.io?manufacturer=Cinelli)

If you submit a year in the request, the response is an array of the model names from that year (not wrapped in a hash), eg [BikeBook.io?manufacturer=Cinelli&year=2014](http://bikebook.io?manufacturer=Cinelli&year=2014)

For all the manufacturers and all the years, [BikeBook.io/assets/index.json](http://bikebook.io/assets/index.json)

#### Get Information about a bike

You need to submit three things to get information about a bike: `manufacturer`, `year` and `frame_model`.

So for a Fuji Outland 29 1.1 from 2014,

[BikeBook.io?manufacturer=fuji&year=2014&frame_model=Outland 29 1.1](http://bikebook.io/?manufacturer=fuji&year=2014&frame_model=Outland%2029%201.1)

Also, since it's a query string, position of the key doesn't matter, i.e. `frame_model` can come first or last.



#### Errors

If we can't find what you've asked for, we return a 404 status error.

## Requests

Feel free to make GET requests to BikeBook from your application. We'll send you JSON back, regardless of domain.

BikeBook.io uses Cross-Origin Resource Sharing (CORS), which allows web applications to make cross domain AJAX calls without using workarounds such as JSONP. For more information about read [this post about CORS](http://www.nczonline.net/blog/2010/05/25/cross-domain-ajax-with-cross-origin-resource-sharing/) (or [the spec](http://www.w3.org/TR/access-control/#simple-cross-origin-request-and-actual-r) if you're hardcore).

## Development, localness, party

#### Contributing

All the bikes data is stored this repository in JSON files. So if you see a mistake or want to update something, do it!

#### Running it

Locally we use [rerun](https://github.com/alexch/rerun) to restart the app on changes. Launch the app in development mode with `rerun 'rackup'`. You can run the tests with `rerun 'rake spec'`.

Asset compilation with `sass --watch assets/styles/style.scss:public/site.css` and `coffee -cw -o public/  assets/scripts/site.coffee`, lazy for now.

Every time you change the filesystem you have to refresh the indexes with `rake refresh` because, flat files.


#### p.s.

Built with all the love by the [Bike Index](https://bikeindex.org).
