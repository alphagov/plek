require_relative "test_helper"

describe Plek do
  before do
    ENV.delete("PLEK_SERVICE_CHEESE_URI")
  end

  it "should return a URI object for the webite root" do
    ENV["GOVUK_WEBSITE_ROOT"] = "https://www.test.gov.uk"
    assert_equal URI.parse("https://www.test.gov.uk"), Plek.new.website_uri
  end

  it "should return a URI object for the asset root" do
    ENV["GOVUK_ASSET_ROOT"] = "https://assets.test.gov.uk"
    assert_equal URI.parse("https://assets.test.gov.uk"), Plek.new.asset_uri
  end

  it "should return a URI object for a service" do
    service_uri = Plek.new("test.gov.uk").find_uri("cheese")
    assert_equal "cheese.test.gov.uk", service_uri.host
  end

  it "should return an HTTPS URI by default" do
    service_uri = Plek.new("test.gov.uk").find_uri("cheese")
    assert_equal "https", service_uri.scheme
  end

  it "should return an HTTP URI when told" do
    service_uri = Plek.new("test.gov.uk").find_uri("cheese", force_http: true)
    assert_equal "http", service_uri.scheme
  end

  it "should raise an error when given an invalid URI" do
    ENV["PLEK_SERVICE_CHEESE_URI"] = "http://mouldy|cheese.test.gov.uk"
    assert_raises URI::InvalidURIError do
      Plek.new.find_uri("cheese")
    end
  end
end
