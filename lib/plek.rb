require 'builder'
require 'plek/version'

class Plek
  DEFAULT_PATTERN = "pattern".freeze
  DEFAULT_DOMAIN = ENV['GOVUK_APP_DOMAIN'] || 'test.gov.uk'
  HTTP_DOMAINS = ['test.gov.uk', 'dev.gov.uk']

  attr_accessor :parent_domain

  def initialize(domain_to_use = nil)
    self.parent_domain = domain_to_use || DEFAULT_DOMAIN
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
end
