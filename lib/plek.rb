require "plek/version"
require "uri"

# Plek resolves service names to a corresponding base URL.
#
# It does this by combining the requested service name with information from
# environment variables.  It will raise a {NoConfigurationError} if a required
# environment variable isn't set.
#
# == Development mode fallback defaults
#
# When running development mode (identified by either +RAILS_ENV+ or +RACK_ENV+
# environment variables being set to "development"), Plek provides some default
# values when the necessary environment variables aren't set detailed below.
class Plek
  # Raised when a required environment variable is not set.
  class NoConfigurationError < StandardError; end

  # The fallback parent domain to use in development mode.
  DEV_DOMAIN = "dev.gov.uk".freeze

  attr_reader :parent_domain, :external_domain

  # Construct a new Plek instance.
  #
  # @param domain_to_use [String, nil] Optionally override the parent domain
  #   to use. If unspecified, this uses the +GOVUK_APP_DOMAIN+ environment
  #   variable.
  #
  #   In development mode, this falls back to {DEV_DOMAIN} if the environment
  #   variable is unset.
  # @param external_domain [String, nil] Optionally override the external
  #   domain to use. If unspecified it will fall back to using
  #   +GOVUK_APP_DOMAIN_EXTERNAL+ and if that is unavailable the parent domain
  #   will be used
  def initialize(domain_to_use = nil, external_domain = nil)
    truth_re = /^[1ty]/i
    @parent_domain = domain_to_use || env_var_or_dev_fallback("GOVUK_APP_DOMAIN", DEV_DOMAIN)
    @external_domain = external_domain || ENV.fetch("GOVUK_APP_DOMAIN_EXTERNAL", @parent_domain)
    @host_prefix = ENV.fetch("PLEK_HOSTNAME_PREFIX", "")
    @unprefixable_hosts = ENV.fetch("PLEK_UNPREFIXABLE_HOSTS", "").split(",").map(&:strip)
    @use_http_for_single_label_domains = truth_re.match?(ENV.fetch("PLEK_USE_HTTP_FOR_SINGLE_LABEL_DOMAINS", ""))
  end

  # Find the base URL for a service/application. This constructs the URL from
  # the given hostname and the {#parent_domain}. If the {#parent_domain}
  # matches the {DEV_DOMAIN}, the returned URL will be a http URL, otherwise it
  # will be https.
  #
  # If PLEK_HOSTNAME_PREFIX is present in the environment, it will be prepended
  # to the hostname unless the hostname appears in the comma-separated list
  # PLEK_UNPREFIXABLE_HOSTS.
  #
  # If PLEK_USE_HTTP_FOR_SINGLE_LABEL_DOMAINS=1 in the environment, Plek will use
  # "http" as the URL scheme instead of "https" for single-label domains.
  # Single-label domains are domains with just a single name component, for
  # example "frontend" or "content-store", as opposed to
  # "frontend.example.com" or "content-store.test.govuk.digital".
  #
  # The URL for a given service can be overridden by setting a corresponding
  # environment variable.  eg if +PLEK_SERVICE_EXAMPLE_CHEESE_THING_URI+ was
  # set, +Plek.new.find('example-cheese-thing')+ would return the value of that
  # variable. This overrides both the "internal" and "external" URL for the
  # service. It is not possible to override them separately.
  #
  # @param service [String] the name of the service to lookup.  This should be
  #   the hostname of the service.
  # @param options [Hash]
  # @option options [Boolean] :force_http If true, force the returned URL to be http.
  # @option options [Boolean] :scheme_relative If true, return a URL without a
  #   scheme (eg `//foo.example.com`)
  # @return [String] The base URL for the service.
  def find(service, options = {})
    name = clean_name(service)
    if (service_uri = defined_service_uri_for(name))
      return service_uri
    end

    name = "#{host_prefix}#{name}" unless unprefixable_hosts.include?(name)

    domain = options[:external] ? external_domain : parent_domain
    domain_suffix = domain.empty? ? "" : ".#{domain}"

    scheme = if options[:scheme_relative]
               ""
             elsif options[:force_http] || http_domain?(domain)
               "http:"
             else
               "https:"
             end

    "#{scheme}//#{name}#{domain_suffix}".freeze
  end

  # Find the external URL for a service/application.
  #
  # @param service [String] the name of the service to lookup.  This should be
  #   the hostname of the service.
  # @param options [Hash] see the documentation for find.
  def external_url_for(service, options = {})
    find(service, options.merge(external: true))
  end

  # Find the base URL for a service/application, and parse as a URI object.
  # This wraps #find and returns the parsed result.
  #
  # @param args see {#find}
  # @return [URI::HTTPS,URI::HTTP,URI::Generic] The base URL for the service
  def find_uri(*args)
    URI(find(*args))
  end

  # Find the base URL for assets.
  #
  # @return [String] The assets base URL.
  def asset_root
    env_var_or_dev_fallback("GOVUK_ASSET_ROOT") { find("static") }
  end

  # Find the base URL for the public website frontend.
  #
  # @return [String] The website base URL.
  def website_root
    env_var_or_dev_fallback("GOVUK_WEBSITE_ROOT") { find("www") }
  end

  # Find the base URL for assets.
  #
  # @return [URI::HTTPS,URI::HTTP,URI::Generic] The assets base URL.
  def asset_uri
    URI(asset_root)
  end

  # Find the base URL for the public website frontend.
  #
  # @return [URI::HTTPS,URI::HTTP,URI::Generic] The website base URL.
  def website_uri
    URI(website_root)
  end

  # TODO: clean up all references to these and then remove them.
  class << self
    # This alias allows calls to be made in the old style:
    #     Plek.current.find('foo')
    # as well as the new style:
    #     Plek.new.find('foo')
    alias_method :current, :new

    # Convenience wrapper.  The same as calling +Plek.new.find+.
    # @see #find
    def find(*args)
      new.find(*args)
    end

    # Convenience wrapper.  The same as calling +Plek.new.find_uri+.
    # @see #find_uri
    def find_uri(*args)
      new.find_uri(*args)
    end
  end

private

  attr_reader :host_prefix, :unprefixable_hosts, :use_http_for_single_label_domains

  # TODO: clean up call sites throughout alphagov and then delete clean_name.
  def clean_name(service)
    service.to_s.downcase.strip.gsub(/[^a-z.-]+/, "")
  end

  def http_domain?(domain)
    domain == DEV_DOMAIN || domain == "" && use_http_for_single_label_domains
  end

  def env_var_or_dev_fallback(var_name, fallback_str = nil)
    if (var = ENV[var_name])
      var
    elsif ENV["RAILS_ENV"] == "production" || ENV["RACK_ENV"] == "production"
      raise(NoConfigurationError, "Expected #{var_name} to be set. Perhaps you should run your task through govuk_setenv <appname>?")
    elsif block_given?
      yield
    else
      fallback_str
    end
  end

  def defined_service_uri_for(service)
    service_name = service.upcase.tr("-", "_")
    uri = ENV.fetch("PLEK_SERVICE_#{service_name}_URI", "")
    uri.empty? ? nil : uri
  end
end
