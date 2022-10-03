# CHANGELOG

# Unreleased

  * BREAKING: Remove `Plek.find_uri`, `Plek#find_uri`, `Plek#asset_uri` and
    `Plek#website_uri`these weren't consistent with full interface and are
    barely used. Use `URI(Plek.find('foo'))`, `URI(Plek.new.asset_uri)` or
    `URI(Plek.new.website_uri)` instead.
  * BREAKING: Remove `Plek.current` method, this was deprecated 10 years ago
    and apps should be using `Plek.new` or shorthand alternatives (`Plek.find`)

# 4.1.0

  * Deprecate usage of `Plek.current` this method will be removed in next
    major version. This adds a warning for users.
  * Remove public setter methods for `parent_domain` and `external_domain`.
    These are not used anywhere so there are no API compatibility issues.
  * Allow setting `GOVUK_APP_DOMAIN=""` (empty string). Similarly for
    `GOVUK_APP_DOMAIN_EXTERNAL`. This allows single-label domains to be used in
    service URLs instead of FQDNs, which eliminates a lot of configuration
    complexity when running on Kubernetes. This also paves the way for
    eventually retiring Plek, if we want.
  * Take an optional, comma-separated list of hostnames
    `PLEK_UNPREFIXABLE_HOSTS` not to be prefixed even when
    `PLEK_HOSTNAME_PREFIX` is set. This simplifies the configuration of the
    draft stack in Kubernetes.
  * Support using `http` as the URL scheme for single-label domains when
    `PLEK_USE_HTTP_FOR_SINGLE_LABEL_DOMAINS=1`. (A single-label domain looks
    like `content-store`, as opposed to `content-store.test.govuk.digital`.)
    This is is needed in order to run in Kubernetes without a service mesh,
    without hard-to-maintain configuration logic to generate domains names
    depending on the environment.

# 4.0.0

  * Remove #public_asset_host method since it is no longer used by any GOV.UK apps.

# 3.0.0

  * Remove support for 'DEV_DOMAIN' environment variable

# 2.1.1

  * Fallback to `GOVUK_APP_DOMAIN` when `GOVUK_APP_DOMAIN_EXTERNAL` is not set

# 2.1.0

  * Add support for external domains, and the
    `GOVUK_APP_DOMAIN_EXTERNAL` environment variable.
  * Add the `external_url_for` method for generating external URLs.

# 2.0.0

  * Consistently return a frozen string from the `Plek.find` method.

# 1.12.0

  * Add `Plek.public_asset_host` for accessing `GOVUK_ASSET_HOST` environment variable

# 1.11.0

  * Add `PLEK_HOSTNAME_PREFIX` environment variable, which prepends the contents
    to the returned hostname

# 1.10.0

  * Add `Plek.find_uri` for accessing `URI` objects for any service

# 1.9.0

  * Add `Plek.find` to simplify client interface.

# 1.8.1

  * Remove unused `DEFAULT_PATTERN` constant.

# 1.8.0

  * Add `website_uri` and `asset_uri` methods for accessing URI objects

# 1.7.0

  * Allow clients to request scheme-relative URLs

# 1.6.0

  * Allow custom service URLs through individual environment variables

# 1.5.0

  * Allow clients to request HTTP URLs

# 1.4.0

  * Allow overriding the development domain through an environment variable

# 1.3.1

  * Clean up a redundant dependency on the Builder gem

# 1.3.0

  * Add the `asset_root` method for an environment's static assets

# 1.2.0

  * Add the `website_root` method for an environment's web root

# 1.1.0

  * Provide a sensible default app domain in development

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
      in using an initializer in alphagov-deployment. (non-Plek) e.g.:
      `alphagov-deployment/frontend/to_upload/initializers/preview/mapit.rb`
      specifies the mapit url by having different initializers per environment
      rather than by querying `Plek.current.environment` at runtime.

  * If using `Plek.new` e.g `Plek.new(env_name).find(app)` which would use
    `Plek.current.environment` to source the url. Instead we now pass a domain
    explicitly: `Plek.new('dev.gov.uk').find(app)`.

  * If using `Plek.current.find`:
    * The old special cases have gone. You will need to change code as follows:
      * 'cdn': use the GOVUK_ASSET_ROOT environment variable
      * 'www': use the GOVUK_WEBSITE_ROOT environment variable
      * 'assets': use `Plek.current.find('static')`
      * 'publication-preview': use `Plek.current.find('private-frontend')`

    * For all other cases, `Plek.current.find` will continue to work as before.

  * If you're using:
    * `gds-api-adapters`: ensure you upgrade to at least 4.1.3
    * `govuk_content_models`: ensure you upgrade to at least 2.5.0

  * Remember to check not only your app code for Plek usages, but also any
    initializers it may be configured with capistrano!

  * Plek no longer understands the `test.gov.uk` URLs; all URLs should be
    `dev.gov.uk` instead. Tests which assumed `test.gov.uk` should be changed
    to reflect this.

  * Because plek uses environment variables to configure itself, you will need
    to set up the correct environment, or plek will fail.

    * For running the app on the dev VM, simply prepend command you use to run
      the app with `govuk_setenv <appname>`.

    * Make sure that your test scripts have a sensible default value for the
      `GOVUK_APP_DOMAIN` environment variable. **NB** you should *not* use
      `govuk_setenv` as part of your test harness, for the simple reason that
      you should not be coupling the process of running your tests to a
      particular deployment environment.

    * If you are using [whenever](https://github.com/javan/whenever), you will
      want to add the following code to your schedule.rb:

            set :job_template, "/usr/local/bin/govuk_setenv <appname> /bin/bash -l -c ':job'"
