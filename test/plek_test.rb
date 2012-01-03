require "test/unit"

$LOAD_PATH.unshift("../lib")
require "plek"
require "uri"

class PlekTest < Test::Unit::TestCase
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
end
