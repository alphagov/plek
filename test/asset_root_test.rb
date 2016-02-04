require_relative "test_helper"

describe Plek do
  describe "asset_root" do
    it "returns the GOVUK_ASSET_ROOT env variable" do
      ClimateControl.modify GOVUK_ASSET_ROOT: "http://static.dev.gov.uk" do
        assert_equal "http://static.dev.gov.uk", Plek.new("foo.gov.uk").asset_root
      end
    end

    describe "When GOVUK_ASSET_ROOT env variable isn't set" do
      it "raises an exception if RAILS_ENV is production" do
        ClimateControl.modify RAILS_ENV: "production" do
          assert_raises Plek::NoConfigurationError do
            Plek.new("foo.gov.uk").asset_root
          end
        end
      end

      it "raises an exception if RACK_ENV is production" do
        ClimateControl.modify RACK_ENV: "production" do
          assert_raises Plek::NoConfigurationError do
            Plek.new("foo.gov.uk").asset_root
          end
        end
      end

      it "returns find('static') otherwise" do
        assert_equal "https://static.foo.gov.uk", Plek.new("foo.gov.uk").asset_root
      end
    end
  end
end
