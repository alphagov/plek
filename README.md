# Plek

"Plek" is Afrikaans. It means "Location". Plek is used to generate the correct
base URLs for internal GOV.UK services, eg:

```ruby
Plek.find('frontend')
```

returns `http://frontend.dev.gov.uk` on a development machine and
`https://frontend.publishing.service.gov.uk` on a production machine. This
means we can use this in our code and let our environment configuration figure
out the correct hosts for us at runtime.

## Technical documentation

See the [API docs](http://www.rubydoc.info/gems/plek) for full details of the API.

### Running the test suite

`bundle exec rake`

### Environment variables

#### For base URLs

The base URL Plek uses for each service can be set using environment variables.

Plek will use any variables set matching this pattern:

`PLEK_SERVICE_` + the service name, uppercased with any hyphens converted to underscores + `_URI`.

For example, the variable for `static` would be `PLEK_SERVICE_STATIC_URI`.

#### Others

To override the development environment base domain, set `DEV_DOMAIN`. The default is `dev.gov.uk`. The environment can be set using either `RAILS_ENV` or `RACK_ENV`.

You can prepend strings to the hostnames generated using: `PLEK_HOSTNAME_PREFIX`.

Override the asset URL with: `GOVUK_ASSET_ROOT`. The default is to generate a URL for the `static` service.

Override the website root with `GOVUK_WEBSITE_ROOT`. The default is to generate a URL for the `www` service.

## Licence

[MIT License](LICENCE)

## Versioning policy

This is versioned according to [Semantic Versioning 2.0](http://semver.org/)
