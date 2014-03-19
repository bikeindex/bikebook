#[BikeBook](http://bikebook.io)

This is the repository of cycles and the components they initially come with, built by the [Bike Index](https://bikeindex.org).

It's a JSON API with CORS.

It's all flat files, so if you see a mistake or want to update something, please do it!


--- 

Every time you change the filesystem you have to refresh the indexes with `rake refresh` because, flat files.

---

### Development

We're using [rerun](https://github.com/alexch/rerun) to restart the app on changes. We're also using it for testing. To launch the app in development mode, run `rerun 'rackup'` and to run the tests run `rerun 'rake spec'`.

For assets: `sass --watch assets/styles/style.scss:public/site.css` and `coffee -cw -o public/  assets/scripts/site.coffee`