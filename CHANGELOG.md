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
  * If using Plek.current.find(special_case) e.g. Plek.current.find('cdn'), check whether this is still relevant and what alternative should be used (such as hardcoding an 'if dev' case). Other such special cases include: www, assets, cdn, publication-preview.

  * If you're using:
    *   gds-api-adapters ensure you upgrade to at least 4.0.0
    *   govuk_content_models ensure you upgrade to at least 2.4.0
