CHANGELOG
# 1.0.0

  * Removed all overrides and rely solely on convention and environment variables
  * Removed Plek#environment in favour of standard constructions

## To upgrade:

  * If you are using Plek.current.environment:
    * if it's for an api-adapter, you should upgrade to gds-api-adapters 4.0.0
      and pass in the URL eg change GdsApi::ContentApi.new(Plek.current.environment) to
      GdsApi::ContentApi.new(Plek.current.find('contentapi'))
    * if it's for something else, consider if the configuration can instead be passed
      in using an initializer in alphagov-deployment. (non-Plek) eg:
      alphagov-deployment/frontend/to_upload/initializers/preview/mapit.rb
      specifies the mapit url by having different initializers per environment
      rather than by querying Plek.current.environment at runtime.
  * If using Plek.new e.g Plek.new(env_name).find(app) which would use Plek.current.environment to source the url. Instead we now pass a domain explicitly: Plek.new('dev.gov.uk').find(app).
  * If using Plek.current.find:
    * The old special cases have gone. You will need to change code as follows:
      * 'cdn': use the GOVUK_ASSET_ROOT environment variable
      * 'www': use the GOVUK_WEBSITE_ROOT environment variable
      * 'assets': use Plek.current.find('static')
      * 'publication-preview': use Plek.current.find('private-frontend')
    * For all other cases, Plek.current.find will continue to work as before.

  * If you're using:
    *   gds-api-adapters ensure you upgrade to at least 4.0.0
    *   govuk_content_models ensure you upgrade to at least 2.4.0
