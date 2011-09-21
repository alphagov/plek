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

  def find service
    # FIXME: *Everything* should be SSL
    "http://#{name_for(service)}.#{domain}"
  end

  %W(panopticon sign-on-o-tron imminence publisher need-o-tron frontend).each do |service|
    define_method service.gsub(/[^a-z]+/, '_') do
      find service
    end
  end

  def name_for service
    case service.to_s.strip
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
