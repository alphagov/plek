require 'builder'
require 'plek/version'

class Plek
  class NoConfigurationError < StandardError; end
  DEFAULT_PATTERN = "pattern".freeze
  HTTP_DOMAINS = ['dev.gov.uk']

  attr_accessor :parent_domain

  def initialize(domain_to_use = nil)
    self.parent_domain = domain_to_use || env_var_or_dev_fallback('GOVUK_APP_DOMAIN', 'dev.gov.uk')
  end

  # Find the URI for a service/application.
  def find(service)
    name = name_for(service)
    host = "#{name}.#{parent_domain}"

    if HTTP_DOMAINS.include?(parent_domain)
      "http://#{host}"
    else
      "https://#{host}"
    end
  end

  def website_root
    env_var_or_dev_fallback('GOVUK_WEBSITE_ROOT') { find('www') }
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
  end

  private

  def env_var_or_dev_fallback(var_name, fallback_str = nil)
    if var = ENV[var_name]
      var
    elsif ENV['RAILS_ENV'] == 'production' || ENV['RACK_ENV'] == 'production'
      raise(NoConfigurationError, "Expected #{var_name} to be set. Perhaps you should run your task through govuk_setenv <appname>?")
    elsif block_given?
      yield
    else
      fallback_str
    end
  end
end
