require 'plek/version'
require 'uri'

class Plek
  class NoConfigurationError < StandardError; end
  DEV_DOMAIN = ENV['DEV_DOMAIN'] || 'dev.gov.uk'
  HTTP_DOMAINS = [ DEV_DOMAIN ]

  attr_accessor :parent_domain

  def initialize(domain_to_use = nil)
    self.parent_domain = domain_to_use || env_var_or_dev_fallback("GOVUK_APP_DOMAIN", DEV_DOMAIN)
  end

  # Find the URI for a service/application.
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

  def asset_root
    env_var_or_dev_fallback("GOVUK_ASSET_ROOT") { find("static") }
  end

  def website_root
    env_var_or_dev_fallback("GOVUK_WEBSITE_ROOT") { find("www") }
  end

  def asset_uri
    URI(asset_root)
  end

  def website_uri
    URI(website_root)
  end

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

    def find(*args)
      new.find(*args)
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
