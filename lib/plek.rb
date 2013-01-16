require 'builder'
require 'plek/version'

class Plek
  class NoConfigurationError < StandardError; end
  DEFAULT_PATTERN = "pattern".freeze
  HTTP_DOMAINS = ['dev.gov.uk']

  attr_accessor :parent_domain

  def initialize(domain_to_use = nil)
    self.parent_domain = domain_to_use || ENV['GOVUK_APP_DOMAIN'] || default_parent_domain
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

  def default_parent_domain
    if ENV['RAILS_ENV'] == 'production' || ENV['RACK_ENV'] == 'production'
      raise(NoConfigurationError, 'Expected GOVUK_APP_DOMAIN to be set. Perhaps you should run your task through govuk_setenv <appname>?')
    else
      'dev.gov.uk'
    end
  end
end
