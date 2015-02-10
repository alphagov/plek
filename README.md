# Plek

"Plek" is Afrikaans. It means "Location". Plek is used to generate the correct
base URLs for internal GOV.UK services, eg:

```ruby
Plek.find('frontend')
```

returns `http://frontend.dev.gov.uk` on a development machine and
`https://frontend.production.alphagov.co.uk` on a production machine. This
means we can use this in our code and let our environment configuration figure
out the correct hosts for us at runtime.

## Technical documentation

See the [API docs](http://www.rubydoc.info/gems/plek) for full details of the API.

### Running the test suite

`bundle exec rake`

## Licence

[MIT License](LICENCE)

## Versioning policy

This is versioned according to [Semantic Versioning 2.0](http://semver.org/)
