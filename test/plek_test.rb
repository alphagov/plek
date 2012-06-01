require "test/unit"

$LOAD_PATH.unshift("../lib")
require "plek"
require "uri"

class PlekTest < Test::Unit::TestCase
  def test_should_return_whitehall_test_host_domain
    whitehall_url = Plek.new("test").find("whitehall")
    assert_equal "whitehall.test.alphagov.co.uk", URI.parse(whitehall_url).host
  end

  def test_should_return_whitehall_preview_host_domain
    whitehall_url = Plek.new("preview").find("whitehall")
    assert_equal "whitehall.preview.alphagov.co.uk", URI.parse(whitehall_url).host
  end

  def test_should_return_whitehall_production_host_domain
    whitehall_url = Plek.new("production").find("whitehall")
    assert_equal "whitehall.production.alphagov.co.uk", URI.parse(whitehall_url).host
  end

  def test_should_return_whitehall_search_test_host_domain
    whitehall_search_url = Plek.new("test").find("whitehall-search")
    assert_equal "whitehall-search.test.alphagov.co.uk", URI.parse(whitehall_search_url).host
  end

  def test_should_return_whitehall_search_preview_host_domain
    whitehall_search_url = Plek.new("preview").find("whitehall-search")
    assert_equal "whitehall-search.preview.alphagov.co.uk", URI.parse(whitehall_search_url).host
  end

  def test_should_return_whitehall_search_production_host_domain
    whitehall_search_url = Plek.new("production").find("whitehall-search")
    assert_equal "whitehall-search.production.alphagov.co.uk", URI.parse(whitehall_search_url).host
  end

  def test_should_return_whitehall_preview_host_url_as_non_ssl
    whitehall_url = Plek.new("preview").find("whitehall")
    assert_equal "http", URI.parse(whitehall_url).scheme
  end

  def test_should_return_whitehall_production_host_url_as_non_ssl
    whitehall_url = Plek.new("production").find("whitehall")
    assert_equal "http", URI.parse(whitehall_url).scheme
  end

  def test_should_return_whitehall_search_preview_host_url_as_non_ssl
    whitehall_search_url = Plek.new("preview").find("whitehall-search")
    assert_equal "http", URI.parse(whitehall_search_url).scheme
  end

  def test_should_return_whitehall_search_production_host_url_as_non_ssl
    whitehall_search_url = Plek.new("production").find("whitehall-search")
    assert_equal "http", URI.parse(whitehall_search_url).scheme
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

  def test_should_return_search_as_non_ssl
    url = Plek.new("production").find("search")
    assert_equal "http", URI.parse(url).scheme
  end

  def test_should_return_tariff_preview_host_domain
    tariff_url = Plek.new("preview").find("tariff")
    assert_equal "https://tariff.preview.alphagov.co.uk", tariff_url
  end
end
