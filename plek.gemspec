lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require "plek/version"

Gem::Specification.new do |s|
  s.name        = "plek"
  s.version     = Plek::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["GOV.UK Dev"]
  s.email       = ["govuk-dev@digital.cabinet-office.gov.uk"]
  s.summary     = "Locations for services"
  s.description = "Find the right hostname for each service in an environment-dependent manner"
  s.license     = "MIT"

  s.files        = Dir.glob("lib/**/*") + %w[LICENCE README.md]
  s.require_path = "lib"
  s.add_development_dependency "climate_control"
  s.add_development_dependency "minitest"
  s.add_development_dependency "rake"
  s.add_development_dependency "rubocop-govuk"
end
