require 'plek/version'

class Plek
  DOMAIN = {
    "test"        => "test.gov.uk",
    "development" => "dev.gov.uk"
  }

  attr_accessor :environment
  private :environment=, :environment

  def initialize environment
    self.environment = environment
  end

  %W(panopticon sign-on-o-tron imminence publisher need-o-tron frontend).each do |service|
    # FIXME: *Everything* should be SSL
    define_method service.gsub(/[^a-z]+/, '_') do
      "http://#{name_for(service)}.#{domain}"
    end
  end

  def name_for service
    case service
    when 'frontend'
      'www'
    else
      service.gsub(/[^a-z]+/, '')
    end
  end

  def domain
    DOMAIN[environment]
  end

  def self.current
    env = ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
    Plek.new env
  end
end
