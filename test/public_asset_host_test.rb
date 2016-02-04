require_relative "test_helper"

describe Plek do
  describe "public_asset_host" do
    it "returns the GOVUK_ASSET_HOST env variable" do
      ClimateControl.modify GOVUK_ASSET_HOST: "https://assets.digital.cabinet-office.gov.uk" do
        assert_equal "https://assets.digital.cabinet-office.gov.uk", Plek.new("foo.gov.uk").public_asset_host
      end
    end

    describe "When GOVUK_ASSET_HOST env variable isn't set" do
      it "raises an exception if RAILS_ENV is production" do
        ClimateControl.modify RAILS_ENV: "production" do
          assert_raises Plek::NoConfigurationError do
            Plek.new("foo.gov.uk").public_asset_host
          end
        end
      end

      it "raises an exception if RACK_ENV is production" do
        ClimateControl.modify RACK_ENV: "production" do
          assert_raises Plek::NoConfigurationError do
            Plek.new("foo.gov.uk").public_asset_host
          end
        end
      end

      it "returns find('static') otherwise" do
        assert_equal "https://static.foo.gov.uk", Plek.new("foo.gov.uk").public_asset_host
      end
    end
  end
end
