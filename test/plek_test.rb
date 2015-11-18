require_relative "test_helper"

class PlekTest < MiniTest::Unit::TestCase
  def test_should_return_whitehall_test_host_domain
    whitehall_url = Plek.new("test.gov.uk").find("whitehall")
    assert_equal "whitehall.test.gov.uk", URI.parse(whitehall_url).host
  end

  def test_should_return_whitehall_preview_host_domain
    whitehall_url = Plek.new("preview.alphagov.co.uk").find("whitehall")
    assert_equal "whitehall.preview.alphagov.co.uk", URI.parse(whitehall_url).host
  end

  def test_should_return_whitehall_production_host_domain
    whitehall_url = Plek.new("production.alphagov.co.uk").find("whitehall")
    assert_equal "whitehall.production.alphagov.co.uk", URI.parse(whitehall_url).host
  end

  def test_should_return_non_whitehall_preview_host_url_as_ssl
    url = Plek.new("preview.alphagov.co.uk").find("non-whitehall-service")
    assert_equal "https", URI.parse(url).scheme
  end

  def test_should_return_non_whitehall_production_host_url_as_ssl
    url = Plek.new("production.alphagov.co.uk").find("non-whitehall-service")
    assert_equal "https", URI.parse(url).scheme
  end

  def test_should_magically_return_http_for_dev_gov_uk
    ENV['GOVUK_APP_DOMAIN'] = 'dev.gov.uk'
    url = Plek.new.find("non-whitehall-service")
    assert_equal "http", URI.parse(url).scheme
  ensure
    ENV.delete("GOVUK_APP_DOMAIN")
  end

  def test_should_return_http_when_requested
    url = Plek.new("production.alphagov.co.uk").find("non-whitehall-service", :force_http => true)
    assert_equal "http", URI.parse(url).scheme
  end

  def test_should_return_tariff_preview_host_domain
    tariff_url = Plek.new("preview.alphagov.co.uk").find("tariff")
    assert_equal "https://tariff.preview.alphagov.co.uk", tariff_url
  end

  def test_should_return_subdomain_divided_source_in_dev
    url = Plek.new("dev.gov.uk").find("explore.reviewomatic")
    assert_equal "http://explore.reviewomatic.dev.gov.uk", url
  end

  def test_should_return_subdomain_divided_source_in_preview
    url = Plek.new("preview.alphagov.co.uk").find("explore.reviewomatic")
    assert_equal "https://explore.reviewomatic.preview.alphagov.co.uk", url
  end

  def test_should_return_subdomain_divided_source_in_production
    url = Plek.new("production.alphagov.co.uk").find("explore.reviewomatic")
    assert_equal "https://explore.reviewomatic.production.alphagov.co.uk", url
  end

  def test_should_return_dash_divided_source_in_dev
    url = Plek.new("dev.gov.uk").find("explore-reviewomatic")
    assert_equal "http://explore-reviewomatic.dev.gov.uk", url
  end

  def test_should_return_dash_divided_source_in_preview
    url = Plek.new("preview.alphagov.co.uk").find("explore-reviewomatic")
    assert_equal "https://explore-reviewomatic.preview.alphagov.co.uk", url
  end

  def test_should_return_dash_divided_source_in_production
    url = Plek.new("production.alphagov.co.uk").find("explore-reviewomatic")
    assert_equal "https://explore-reviewomatic.production.alphagov.co.uk", url
  end

  def test_should_be_able_to_use_current_for_old_style_calls
    ENV['GOVUK_APP_DOMAIN'] = 'foo.bar.baz'
    assert_equal Plek.new.find("foo"), Plek.current.find("foo")
  ensure
    ENV.delete("GOVUK_APP_DOMAIN")
  end

  def test_should_be_able_to_avoid_instantiation_in_the_client
    ENV['GOVUK_APP_DOMAIN'] = 'foo.bar.baz'
    assert_equal Plek.new.find("foo"), Plek.find("foo")
  ensure
    ENV.delete("GOVUK_APP_DOMAIN")
  end

  def test_should_be_able_to_avoid_instantiation_with_uris
    ENV['GOVUK_APP_DOMAIN'] = 'foo.bar.baz'
    assert_equal Plek.new.find_uri("foo"), Plek.find_uri("foo")
  ensure
    ENV.delete("GOVUK_APP_DOMAIN")
  end

  def test_should_prepend_data_from_the_environment
    ENV['PLEK_HOSTNAME_PREFIX'] = 'test-'
    assert_equal "https://test-foo.preview.alphagov.co.uk", Plek.new("preview.alphagov.co.uk").find("foo")
  ensure
    ENV.delete("PLEK_HOSTNAME_PREFIX")
  end

  def test_scheme_relative_urls
    url = Plek.new("dev.gov.uk").find("service", scheme_relative: true)
    assert_equal "//service.dev.gov.uk", url
  end

  def test_should_detect_dev_environment
    assert_equal "development", Plek.new("dev.gov.uk").environment
  end

  def test_should_detect_preview_environment_as_integration
    assert_equal "integration", Plek.new("preview.alphagov.co.uk").environment
  end

  def test_should_detect_integration_environment
    assert_equal "integration", Plek.new("integration.publishing.service.gov.uk").environment
  end

  def test_should_detect_staging_environment
    assert_equal "staging", Plek.new("staging.publishing.service.gov.uk").environment
  end

  def test_should_detect_production_environment
    assert_equal "production", Plek.new("publishing.service.gov.uk").environment
  end

  def test_should_default_to_development_environment
    assert_equal "development", Plek.new("foo.bar.baz").environment
  end

  def test_environment_convenience_function
    assert_equal "development", Plek.environment
  end
end
