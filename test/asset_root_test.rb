require_relative "test_helper"

describe Plek do
  describe "retreiving the asset_root" do
    it "should return the GOVUK_ASSET_ROOT env variable" do
      ClimateControl.modify GOVUK_ASSET_ROOT: "http://static.dev.gov.uk" do
        assert_equal "http://static.dev.gov.uk", Plek.new("foo.gov.uk").asset_root
      end
    end

    describe "When GOVUK_ASSET_ROOT env variable isn't set" do
      it "should raise an exception if RAILS_ENV is production" do
        ClimateControl.modify RAILS_ENV: "production" do
          assert_raises Plek::NoConfigurationError do
            Plek.new("foo.gov.uk").asset_root
          end
        end
      end

      it "should raise an exception if RACK_ENV is production" do
        ClimateControl.modify RACK_ENV: "production" do
          assert_raises Plek::NoConfigurationError do
            Plek.new("foo.gov.uk").asset_root
          end
        end
      end

      it "should return find('static') otherwise" do
        assert_equal "https://static.foo.gov.uk", Plek.new("foo.gov.uk").asset_root
      end
    end
  end
end
