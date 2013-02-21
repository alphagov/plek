require_relative "test_helper"

describe Plek do
  before do
    ENV.delete("GOVUK_ASSET_ROOT")
    ENV.delete("RAILS_ENV")
    ENV.delete("RACK_ENV")
  end

  describe "retreiving the asset_host" do
    it "should return the GOVUK_ASSET_ROOT env variable" do
      ENV["GOVUK_ASSET_ROOT"] = "http://static.dev.gov.uk"
      assert_equal "http://static.dev.gov.uk", Plek.new("foo.gov.uk").asset_root
    end

    describe "When GOVUK_ASSET_ROOT env variable isn't set" do
      it "should raise an exception if RAILS_ENV is production" do
        ENV["RAILS_ENV"] = "production"
        assert_raises Plek::NoConfigurationError do
          Plek.new("foo.gov.uk").asset_root
        end
      end

      it "should raise an exception if RACK_ENV is production" do
        ENV["RACK_ENV"] = "production"
        assert_raises Plek::NoConfigurationError do
          Plek.new("foo.gov.uk").asset_root
        end
      end

      it "should return find('static') otherwise" do
        assert_equal "https://static.foo.gov.uk", Plek.new("foo.gov.uk").asset_root
      end
    end
  end
end
