require_relative "test_helper"

describe Plek do
  before do
    ENV.delete('GOVUK_WEBSITE_ROOT')
    ENV.delete('RAILS_ENV')
    ENV.delete('RACK_ENV')
  end

  describe "retreiving the website_root" do
    it "should return the GOVUK_WEBSITE_ROOT env variable" do
      ENV['GOVUK_WEBSITE_ROOT'] = "https://www.test.gov.uk"
      assert_equal "https://www.test.gov.uk", Plek.new('foo.gov.uk').website_root
    end

    describe "When GOVUK_WEBSITE_ROOT env variable isn't set" do
      it "should raise an exception if RAILS_ENV is production" do
        ENV['RAILS_ENV'] = 'production'
        assert_raises Plek::NoConfigurationError do
          Plek.new('foo.gov.uk').website_root
        end
      end

      it "should raise an exception if RACK_ENV is production" do
        ENV['RACK_ENV'] = 'production'
        assert_raises Plek::NoConfigurationError do
          Plek.new('foo.gov.uk').website_root
        end
      end

      it "should return find('www') otherwise" do
        assert_equal "https://www.foo.gov.uk", Plek.new('foo.gov.uk').website_root
      end
    end
  end
end
