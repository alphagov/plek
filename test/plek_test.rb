require "test/unit"

$LOAD_PATH.unshift("../lib")
require "plek"
require "uri"

class PlekTest < Test::Unit::TestCase
  def test_should_return_whitehall_test_host_domain
    whitehall_url = Plek.new("test").find("whitehall")
    assert_equal "whitehall.test.gov.uk", URI.parse(whitehall_url).host
  end

  def test_should_return_non_whitehall_preview_host_url_as_ssl
    url = Plek.new("preview").find("non-whitehall-service")
    assert_equal "https", URI.parse(url).scheme
  end

  def test_should_return_non_whitehall_production_host_url_as_ssl
    url = Plek.new("production").find("non-whitehall-service")
    assert_equal "https", URI.parse(url).scheme
  end

  def test_should_return_non_whitehall_non_preview_and_non_production_host_url_as_non_ssl
    url = Plek.new("development").find("non-whitehall-service")
    assert_equal "http", URI.parse(url).scheme
  end

  def test_should_return_subdomain_divided_source_in_dev
    url = Plek.new("development").find("explore.reviewomatic")
    assert_equal "http://explore.reviewomatic.dev.gov.uk", url
  end
end
