require 'builder'
require 'plek/version'

class Plek
  class NoConfigurationError < StandardError; end
  DEFAULT_PATTERN = "pattern".freeze
  HTTP_DOMAINS = ['dev.gov.uk']

  attr_accessor :parent_domain

  def initialize(domain_to_use = nil)
    self.parent_domain = domain_to_use || self.class.default_parent_domain || ENV['GOVUK_APP_DOMAIN'] || raise(NoConfigurationError, 'Expected GOVUK_APP_DOMAIN to be set. Perhaps you should run your task through govuk_setenv <appname>?')
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

    # Allow setting a class-level default domain to use when none is given
    # This is intended to be used in test setups to insulate the tests from the environment
    @default_parent_domain = nil
    attr_accessor :default_parent_domain
  end
end
