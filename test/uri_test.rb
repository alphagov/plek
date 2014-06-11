require_relative "test_helper"

describe Plek do
  it "should return a URI object for the webite root" do
    ENV["GOVUK_WEBSITE_ROOT"] = "https://www.test.gov.uk"
    assert_equal URI.parse("https://www.test.gov.uk"), Plek.new.website_uri
  end

  it "should return a URI object for the asset root" do
    ENV["GOVUK_ASSET_ROOT"] = "https://assets.test.gov.uk"
    assert_equal URI.parse("https://assets.test.gov.uk"), Plek.new.asset_uri
  end
end
