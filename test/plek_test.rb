require_relative "test_helper"

class PlekTest < Minitest::Test
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
    ClimateControl.modify GOVUK_APP_DOMAIN: "dev.gov.uk" do
      url = Plek.new.find("non-whitehall-service")
      assert_equal "http", URI.parse(url).scheme
    end
  end

  def test_should_return_http_when_requested
    url = Plek.new("production.alphagov.co.uk").find("non-whitehall-service", force_http: true)
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
    ClimateControl.modify GOVUK_APP_DOMAIN: "foo.bar.baz" do
      assert_equal Plek.new.find("foo"), Plek.current.find("foo")
    end
  end

  def test_should_be_able_to_avoid_instantiation_in_the_client
    ClimateControl.modify GOVUK_APP_DOMAIN: "foo.bar.baz" do
      assert_equal Plek.new.find("foo"), Plek.find("foo")
    end
  end

  def test_should_be_able_to_avoid_instantiation_with_uris
    ClimateControl.modify GOVUK_APP_DOMAIN: "foo.bar.baz" do
      assert_equal Plek.new.find_uri("foo"), Plek.find_uri("foo")
    end
  end

  def test_should_prepend_data_from_the_environment
    ClimateControl.modify PLEK_HOSTNAME_PREFIX: "test-" do
      assert_equal "https://test-foo.preview.alphagov.co.uk", Plek.new("preview.alphagov.co.uk").find("foo")
    end
  end

  def test_scheme_relative_urls
    url = Plek.new("dev.gov.uk").find("service", scheme_relative: true)
    assert_equal "//service.dev.gov.uk", url
  end

  def test_should_return_external_domain
    ClimateControl.modify GOVUK_APP_DOMAIN_EXTERNAL: "baz.external" do
      assert_equal "http://foo.baz.external", Plek.new.external_url_for("foo")
    end
  end
end
