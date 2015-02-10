require 'plek/version'
require 'uri'

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
  DEV_DOMAIN = ENV['DEV_DOMAIN'] || 'dev.gov.uk'

  # Domains to return http URLs for.
  HTTP_DOMAINS = [ DEV_DOMAIN ]

  attr_accessor :parent_domain

  # Construct a new Plek instance.
  #
  # @param domain_to_use [String] Optionally override the parent domain to use.
  #   If unspecified, this uses the +GOVUK_APP_DOMAIN+ environment variable.
  #
  #   In development mode, this falls back to {DEV_DOMAIN} if the environment
  #   variable is unset.
  def initialize(domain_to_use = nil)
    self.parent_domain = domain_to_use || env_var_or_dev_fallback("GOVUK_APP_DOMAIN", DEV_DOMAIN)
  end

  # Find the base URL for a service/application. This constructs the URL from
  # the given hostname and the {#parent_domain}. If the {#parent_domain}
  # matches the {DEV_DOMAIN}, the returned URL will be a http URL, otherwise it
  # will be https.
  #
  # The URL for a given service can be overridden by setting a corresponding
  # environment variable.  eg if +PLEK_SERVICE_EXAMPLE_CHEESE_THING_URI+ was
  # set, +Plek.new.find('example-cheese-thing')+ would return the value of that
  # variable.
  #
  # @param service [String] the name of the service to lookup.  This should be
  #   the hostname of the service.
  # @param options [Hash]
  # @option options [Boolean] :force_http If true, force the returned URL to be http.
  # @option options [Boolean] :scheme_relative If true, return a URL without a
  #   scheme (eg `//foo.example.com`)
  # @return [String] The base URL for the service.
  def find(service, options = {})
    name = name_for(service)
    if service_uri = defined_service_uri_for(name)
      return service_uri
    end

    host = "#{name}.#{parent_domain}"

    if options[:scheme_relative]
      "//#{host}"
    elsif options[:force_http] or HTTP_DOMAINS.include?(parent_domain)
      "http://#{host}"
    else
      "https://#{host}"
    end
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

  # @api private
  def name_for(service)
    name = service.to_s.dup
    name.downcase!
    name.strip!
    name.gsub!(/[^a-z\.-]+/, '')
    name
  end

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

  def env_var_or_dev_fallback(var_name, fallback_str = nil)
    if var = ENV[var_name]
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
    service_name = service.upcase.gsub(/-/,'_')
    var_name = "PLEK_SERVICE_#{service_name}_URI"

    if (uri = ENV[var_name] and ! uri.empty?)
      return uri
    end
    return nil
  end
end
