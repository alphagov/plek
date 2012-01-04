require 'builder'
require 'plek/version'

class Plek
  DEFAULT_PATTERN = "pattern".freeze

  SERVICES = {
    "production.frontend"            => "www.production.alphagov.co.uk",
    "production.authentication"      => "signonotron.production.alphagov.co.uk",
    "production.needs"               => "needotron.production.alphagov.co.uk",
    "production.data"                => "imminence.production.alphagov.co.uk",
    "production.arbiter"             => "panopticon.production.alphagov.co.uk",
    "production.assets"              => "static.production.alphagov.co.uk",
    "production.publicationpreview"  => "private-frontend.production.alphagov.co.uk",
    "production.whitehall"           => "whitehall.production.alphagov.co.uk",
    "production.whitehallsearch"     => "whitehall-search.production.alphagov.co.uk",
    "production.#{DEFAULT_PATTERN}"  => "%s.production.alphagov.co.uk",

    "preview.frontend"               => "www.preview.alphagov.co.uk",
    "preview.authentication"         => "signonotron.preview.alphagov.co.uk",
    "preview.needs"                  => "needotron.preview.alphagov.co.uk",
    "preview.data"                   => "imminence.preview.alphagov.co.uk",
    "preview.arbiter"                => "panopticon.preview.alphagov.co.uk",
    "preview.assets"                 => "static.preview.alphagov.co.uk",
    "preview.publicationpreview"     => "private-frontend.preview.alphagov.co.uk",
    "preview.whitehall"              => "whitehall.preview.alphagov.co.uk",
    "preview.whitehallsearch"        => "whitehall-search.preview.alphagov.co.uk",
    "preview.#{DEFAULT_PATTERN}"     => "%s.preview.alphagov.co.uk",

    "staging.frontend"               => "demo.alphagov.co.uk",
    "staging.authentication"         => "signonotron.alpha.gov.uk",
    "staging.needs"                  => "needotron.alpha.gov.uk",
    "staging.publisher"              => "guides.staging.alphagov.co.uk",
    "staging.data"                   => "imminence.staging.alphagov.co.uk",
    "staging.arbiter"                => "panopticon.staging.alphagov.co.uk",
    "staging.assets"                 => "static.staging.alphagov.co.uk",
    "staging.publicationpreview"     => "private-frontend.staging.alphagov.co.uk",
    "staging.#{DEFAULT_PATTERN}"     => "%s.staging.alphagov.co.uk",

    "development.authentication"     => "signonotron.dev.gov.uk",
    "development.needs"              => "needotron.dev.gov.uk",
    "development.data"               => "imminence.dev.gov.uk",
    "development.arbiter"            => "panopticon.dev.gov.uk",
    "development.assets"             => "static.dev.gov.uk",
    "development.publicationpreview" => "www.dev.gov.uk",
    "development.#{DEFAULT_PATTERN}" => "%s.dev.gov.uk",

    "test.authentication"            => "signonotron.test.gov.uk",
    "test.needs"                     => "needotron.test.gov.uk",
    "test.data"                      => "imminence.test.gov.uk",
    "test.arbiter"                   => "panopticon.test.gov.uk",
    "test.publicationpreview"        => "www.test.gov.uk",
    "test.whitehall"                 => "whitehall.test.alphagov.co.uk",
    "test.whitehallsearch"           => "whitehall-search.test.alphagov.co.uk",
    "test.#{DEFAULT_PATTERN}"        => "%s.test.gov.uk",
  }.freeze

  SERVICE_TOKENS = %w(
    frontend
    authentication
    needs
    publisher
    data
    arbiter
    search
  ).sort.freeze

  PURPOSE_FOR_SERVICE = {
    "need-o-tron"    => "needs",
    "sign-on-o-tron" => "authentication",
    "imminence"      => "data",
    "panopticon"     => "arbiter"
  }.freeze

  SERVICE_NAMES = %w(
    panopticon
    sign-on-o-tron
    imminence
    publisher
    need-o-tron
    frontend
    search
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
  #    arbiter: organises data shared between the applications
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
    name.gsub!(/[^a-z]+/, '')
    name
  end

  def self.current
    env = ENV['FACTER_govuk_platform'] || ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
    Plek.new env
  end
end
