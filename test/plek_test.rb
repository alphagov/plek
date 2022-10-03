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

  def test_should_be_able_to_avoid_instantiation_in_the_client
    ClimateControl.modify GOVUK_APP_DOMAIN: "foo.bar.baz" do
      assert_equal Plek.new.find("foo"), Plek.find("foo")
    end
  end

  def test_should_prepend_data_from_the_environment
    ClimateControl.modify PLEK_HOSTNAME_PREFIX: "test-" do
      assert_equal "https://test-foo.preview.alphagov.co.uk", Plek.new("preview.alphagov.co.uk").find("foo")
    end
  end

  def test_unprefixable_hosts_are_not_prefixed
    ClimateControl.modify PLEK_HOSTNAME_PREFIX: "draft-",
                          PLEK_UNPREFIXABLE_HOSTS: "signon,feedback" do
      p = Plek.new("test.govuk.digital")
      assert_equal "https://draft-content-store.test.govuk.digital", p.find("content-store")
      assert_equal "https://signon.test.govuk.digital", p.find("signon")
      assert_equal "https://feedback.test.govuk.digital", p.find("feedback")
    end
  end

  def test_use_http_for_single_label_domains
    ClimateControl.modify PLEK_USE_HTTP_FOR_SINGLE_LABEL_DOMAINS: "1",
                          GOVUK_APP_DOMAIN: "" do
      p = Plek.new
      assert_equal "http://frontend", p.find("frontend")
    end
  end

  def test_http_for_single_label_domains_doesnt_affect_others
    ClimateControl.modify PLEK_USE_HTTP_FOR_SINGLE_LABEL_DOMAINS: "1",
                          GOVUK_APP_DOMAIN: "",
                          GOVUK_APP_DOMAIN_EXTERNAL: "example.com" do
      p = Plek.new
      assert_equal "https://foo.example.com", p.external_url_for("foo")
    end
  end

  def test_dev_domain_is_http_if_no_http_domains_specified
    p = Plek.new
    assert_equal "http://signon.dev.gov.uk", p.find("signon")
  end

  def test_scheme_relative_urls
    url = Plek.new("dev.gov.uk").find("service", scheme_relative: true)
    assert_equal "//service.dev.gov.uk", url
  end

  def test_should_return_external_domain
    ClimateControl.modify GOVUK_APP_DOMAIN_EXTERNAL: "baz.external" do
      assert_equal "https://foo.baz.external", Plek.new.external_url_for("foo")
    end
  end

  def test_should_be_able_to_avoid_initialisation_for_external_domain
    ClimateControl.modify GOVUK_APP_DOMAIN_EXTERNAL: "baz.external" do
      assert_equal "https://foo.baz.external", Plek.external_url_for("foo")
    end
  end

  def test_accepts_empty_domain_suffix
    p = Plek.new("")
    assert_equal "https://content-store", p.find("content-store")
  end

  def test_accepts_empty_domain_suffix_via_environment
    ClimateControl.modify GOVUK_APP_DOMAIN: "",
                          GOVUK_APP_DOMAIN_EXTERNAL: "example.com" do
      assert_equal "https://content-store", Plek.new.find("content-store")
    end
  end

  def test_accepts_valid_service_names
    assert_equal "http://allows-dash-separators.dev.gov.uk", Plek.find("allows-dash-separators")
    assert_equal "http://allows.dot.separators.dev.gov.uk", Plek.find("allows.dot.separators")
    assert_equal "http://allows-numb3r5.dev.gov.uk", Plek.find("allows-numb3r5")
  end

  def test_rejects_invalid_service_names
    assert_raises(ArgumentError) { Plek.find("CAPITAL-LETTERS-ARE-INVALID") }
    assert_raises(ArgumentError) { Plek.find("underscores_arent_allowed") }
    assert_raises(ArgumentError) { Plek.find("invalid-because\nnew-line") }
  end
end
