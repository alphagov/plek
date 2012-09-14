require 'builder'
require 'plek/version'

class Plek
  DEFAULT_PATTERN = "pattern".freeze

  SERVICES = {
    "production.www"                 => "www.gov.uk",
    "production.authentication"      => "signon.production.alphagov.co.uk",
    "production.needs"               => "needotron.production.alphagov.co.uk",
    "production.data"                => "imminence.production.alphagov.co.uk",
    "production.assets"              => "static.production.alphagov.co.uk",
    "production.cdn"                 => "d17tffe05zdvwj.cloudfront.net",
    "production.publication-preview" => "private-frontend.production.alphagov.co.uk",
    "production.whitehall"           => "whitehall.production.alphagov.co.uk",
    "production.whitehall-search"    => "whitehall-search.production.alphagov.co.uk",
    "production.#{DEFAULT_PATTERN}"  => "%s.production.alphagov.co.uk",

    "preview.www"                    => "www.preview.alphagov.co.uk",
    "preview.authentication"         => "signon.preview.alphagov.co.uk",
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
    "staging.authentication"         => "signon.alpha.gov.uk",
    "staging.needs"                  => "needotron.alpha.gov.uk",
    "staging.publisher"              => "guides.staging.alphagov.co.uk",
    "staging.data"                   => "imminence.staging.alphagov.co.uk",
    "staging.assets"                 => "static.staging.alphagov.co.uk",
    "staging.assets"                 => "static.staging.alphagov.co.uk",
    "staging.publication-preview"    => "private-frontend.staging.alphagov.co.uk",
    "staging.#{DEFAULT_PATTERN}"     => "%s.staging.alphagov.co.uk",

    "development.authentication"     => "signon.dev.gov.uk",
    "development.needs"              => "needotron.dev.gov.uk",
    "development.data"               => "imminence.dev.gov.uk",
    "development.assets"             => "static.dev.gov.uk",
    "development.cdn"                => "static.dev.gov.uk",
    "development.whitehall"          => "whitehall.dev.gov.uk",
    "development.whitehall-search"   => "whitehall-search.dev.gov.uk",
    "development.publication-preview"=> "www.dev.gov.uk",
    "development.#{DEFAULT_PATTERN}" => "%s.dev.gov.uk",

    "test.authentication"            => "signon.test.gov.uk",
    "test.needs"                     => "needotron.test.gov.uk",
    "test.data"                      => "imminence.test.gov.uk",
    "test.publication-preview"       => "www.test.gov.uk",
    "test.cdn"                       => "static.test.gov.uk",
    "test.whitehall"                 => "whitehall.test.alphagov.co.uk",
    "test.whitehall-search"          => "whitehall-search.test.alphagov.co.uk",
    "test.#{DEFAULT_PATTERN}"        => "%s.test.gov.uk",
  }.freeze

  SERVICE_TOKENS = %w(
    frontend
    authentication
    needs
    publisher
    data
    search
  ).sort.freeze

  PURPOSE_FOR_SERVICE = {
    "need-o-tron"    => "needs",
    "signon"         => "authentication",
    "imminence"      => "data",
  }.freeze

  SERVICE_NAMES = %w(
    panopticon
    signon
    imminence
    publisher
    need-o-tron
    frontend
    search
    tariff
  ).sort.freeze

  SERVICE_NAMES.each do |service_name|
    # Backward compatibility
    method_name = service_name.gsub(/[^a-z]+/, '_')
    define_method method_name do
      name = PURPOSE_FOR_SERVICE[service_name] || service_name
      puts "Plek##{method_name} is deprecated and will be removed in an " +
           "upcoming release.\nUse `Plek#find('#{name}')` instead."
      find name
    end
  end

  attr_accessor :environment
  private :environment=

  def initialize environment
    self.environment = environment
  end

  def to_xml
    io = StringIO.new
    builder = Builder::XmlMarkup.new :target => io, :spacing => 2
    builder.services :environment => environment do |services|
      SERVICE_TOKENS.each do |token|
        uri = find token
        services.service :token => token, :uri => uri
      end
    end
    io.rewind
    io.string
  end

  # Find the URI for a service.
  #
  # Services don't map directly to applications since we may replace an
  # application but retain the service.
  #
  # Currently we have these services:
  #
  #    frontend: Where the public can see our output.
  #    authentication: Where we send staff so they can log in.
  #    publisher: Where we write content.
  #    needs: Where we record the needs that we're going to fulfill.
  #    data: Where our datasets live.
  #
  def find service
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
