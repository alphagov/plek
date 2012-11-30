CHANGELOG
# 1.0.0

  * Removed all overrides and rely solely on convention and environment variables
  * Removed Plek#environment in favour of standard constructions

## To upgrade:

  * There's a lot here. If you are confused about anything, please talk to the Infrastructure & Tools team.
  * If you are using `Plek.current.environment`:
    * if it's for an api-adapter, you should upgrade to gds-api-adapters >= 4.1.3
      and pass in the URL eg change `GdsApi::ContentApi.new(Plek.current.environment)` to
      `GdsApi::ContentApi.new(Plek.current.find('contentapi'))`
    * if it's for something else, consider if the configuration can instead be passed
      in using an initializer in alphagov-deployment. (non-Plek) eg:
      alphagov-deployment/frontend/to_upload/initializers/preview/mapit.rb
      specifies the mapit url by having different initializers per environment
      rather than by querying `Plek.current.environment` at runtime.
  * If using `Plek.new` e.g `Plek.new(env_name).find(app)` which would use `Plek.current.environment` to source the url. Instead we now pass a domain explicitly: `Plek.new('dev.gov.uk').find(app)`.
  * If using `Plek.current.find`:
    * The old special cases have gone. You will need to change code as follows:
      * 'cdn': use the GOVUK_ASSET_ROOT environment variable
      * 'www': use the GOVUK_WEBSITE_ROOT environment variable
      * 'assets': use `Plek.current.find('static')`
      * 'publication-preview': use `Plek.current.find('private-frontend')`
    * For all other cases, `Plek.current.find` will continue to work as before.

  * If you're using:
    *   gds-api-adapters ensure you upgrade to at least 4.1.3
    *   govuk_content_models ensure you upgrade to at least 2.5.0
  * Remember to check not only your app code for Plek usages, but also any initializers it may be configured with capistrano!
  * Plek no longer understands the `test.gov.uk` URLs; all URLs should be `dev.gov.uk` instead. Tests which assumed `test.gov.uk` should be changed to reflect this.
  * Because plek uses environment variables to configure itself, you will need to set up the correct environment, or plek will fail. Puppet provides a script called `govuk_setenv` to set up the environment correctly for each app.
    * Yes, this is a pain. We would like to work with people to make this less onerous, perhaps by providing some standardized bash aliases.
    * For running tests and other rake tasks, run this:
```
govuk_setenv $APP_NAME bundle exec rake
```
    * For running the app through foreman, simply prepend the existing Procfile command with `govuk_setenv <app-name>`, replacing <app-name> with the actual app name
    * For running rake tasks as part of a capistrano deployment (TBD)
    * If you are using whenever, you will want to add the following code to your schedule.rb:
```ruby
set :job_template, "/usr/local/bin/govuk_setenv #{APP_NAME} /bin/bash -l -c ':job'"
```

