require_relative "test_helper"

describe Plek do
  describe "retreiving the website_root" do
    it "should return the GOVUK_WEBSITE_ROOT env variable" do
      ClimateControl.modify GOVUK_WEBSITE_ROOT: "https://www.test.gov.uk" do
        assert_equal "https://www.test.gov.uk", Plek.new("foo.gov.uk").website_root
      end
    end

    describe "When GOVUK_WEBSITE_ROOT env variable isn't set" do
      it "should raise an exception if RAILS_ENV is production" do
        ClimateControl.modify RAILS_ENV: "production" do
          assert_raises Plek::NoConfigurationError do
            Plek.new("foo.gov.uk").website_root
          end
        end
      end

      it "should raise an exception if RACK_ENV is production" do
        ClimateControl.modify RACK_ENV: "production" do
          assert_raises Plek::NoConfigurationError do
            Plek.new("foo.gov.uk").website_root
          end
        end
      end

      it "should return find('www') otherwise" do
        assert_equal "https://www.foo.gov.uk", Plek.new("foo.gov.uk").website_root
      end
    end
  end
end
