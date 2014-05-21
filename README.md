Plek
====

"Plek" is Afrikaans. It means "Location." Plek is used to generate the correct hostnames for internal GOV.UK services, eg:

```ruby
Plek.current.find('frontend')
```

returns `https://frontend.production.alphagov.co.uk`. This means we can use this in our code and let our environment configuration figure out the correct hosts for us at runtime.

Hacking Plek URLs
-----------------

Plek allows one to alter the URL returned using environment variables, eg:

```shell
PLEK_SERVICE_EXAMPLECHEESETHING_URL=http://example.com bundle exec rails s
```

would set

```ruby
Plek.current.find('example-cheese-thing')
```

to `http://example.com`. Underscores and dashes in Plek names are collapsed in the environment variable as demonstrated.
