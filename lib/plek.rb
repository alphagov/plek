require 'builder'
require 'plek/version'

class Plek
  DEFAULT_PATTERN = "pattern".freeze

  SERVICES = {
    "production.www"                 => "www.gov.uk",
    "production.needs"               => "needotron.production.alphagov.co.uk",
    "production.data"                => "imminence.production.alphagov.co.uk",
    "production.assets"              => "static.production.alphagov.co.uk",
    "production.cdn"                 => "d17tffe05zdvwj.cloudfront.net",
    "production.publication-preview" => "private-frontend.production.alphagov.co.uk",
    "production.whitehall"           => "whitehall.production.alphagov.co.uk",
    "production.whitehall-search"    => "whitehall-search.production.alphagov.co.uk",
    "production.#{DEFAULT_PATTERN}"  => "%s.production.alphagov.co.uk",

    "preview.www"                    => "www.preview.alphagov.co.uk",
    "preview.needs"                  => "needotron.preview.alphagov.co.uk",
    "preview.data"                   => "imminence.preview.alphagov.co.uk",
    "preview.assets"                 => "static.preview.alphagov.co.uk",
    "preview.cdn"                    => "djb1962t8apu5.cloudfront.net",
    "preview.publication-preview"    => "private-frontend.preview.alphagov.co.uk",
    "preview.tariff"                 => "tariff.preview.alphagov.co.uk",
    "preview.whitehall"              => "whitehall.preview.alphagov.co.uk",
    "preview.whitehall-search"       => "whitehall-search.preview.alphagov.co.uk",
    "preview.#{DEFAULT_PATTERN}"     => "%s.preview.alphagov.co.uk",

    "staging.frontend"               => "demo.alphagov.co.uk",
    "staging.needs"                  => "needotron.alpha.gov.uk",
    "staging.publisher"              => "guides.staging.alphagov.co.uk",
    "staging.data"                   => "imminence.staging.alphagov.co.uk",
    "staging.assets"                 => "static.staging.alphagov.co.uk",
    "staging.assets"                 => "static.staging.alphagov.co.uk",
    "staging.publication-preview"    => "private-frontend.staging.alphagov.co.uk",
    "staging.#{DEFAULT_PATTERN}"     => "%s.staging.alphagov.co.uk",

    "development.needs"              => "needotron.dev.gov.uk",
    "development.data"               => "imminence.dev.gov.uk",
    "development.assets"             => "static.dev.gov.uk",
    "development.cdn"                => "static.dev.gov.uk",
    "development.whitehall"          => "whitehall.dev.gov.uk",
    "development.whitehall-search"   => "whitehall-search.dev.gov.uk",
    "development.publication-preview"=> "www.dev.gov.uk",
    "development.#{DEFAULT_PATTERN}" => "%s.dev.gov.uk",

    "test.needs"                     => "needotron.test.gov.uk",
    "test.data"                      => "imminence.test.gov.uk",
    "test.publication-preview"       => "www.test.gov.uk",
    "test.cdn"                       => "static.test.gov.uk",
    "test.whitehall"                 => "whitehall.test.alphagov.co.uk",
    "test.whitehall-search"          => "whitehall-search.test.alphagov.co.uk",
    "test.#{DEFAULT_PATTERN}"        => "%s.test.gov.uk",
  }.freeze

  attr_accessor :environment
  private :environment=

  def initialize environment
    self.environment = environment
  end

  # Find the URI for a service/application.
  def find(service)
    name = name_for service
    host = SERVICES[service_key_for(name)]
    host ||= SERVICES["#{environment}.#{DEFAULT_PATTERN}"].to_s % name
    # FIXME: *Everything* should be SSL
    if whitehall?(service) or search?(service)
      "http://#{host}"
    elsif (environment == 'preview' or environment == 'production')
      "https://#{host}"
    else
      "http://#{host}"
    end
  end

  def whitehall?(service)
    /^whitehall/.match(service)
  end

  def search?(service)
    service == 'search' or service == 'rummager'
  end

  def service_key_for name
    "#{environment}.#{name}"
  end

  def name_for service
    name = service.to_s.dup
    name.downcase!
    name.strip!
    name.gsub!(/[^a-z\.-]+/, '')
    name
  end

  def self.current_env
    if (ENV['RAILS_ENV'] || ENV['RACK_ENV']) == 'test'
      'test'
    else
      ENV['FACTER_govuk_platform'] || ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
    end
  end

  def self.current
    Plek.new(current_env)
  end
end
