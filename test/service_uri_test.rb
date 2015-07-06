require_relative "test_helper"

describe Plek do
  describe "overriding the uri for a service" do
    after do
      ENV.delete("PLEK_SERVICE_FOO_URI")
      ENV.delete("PLEK_SERVICE_BAR_URI")
      ENV.delete("PLEK_SERVICE_FOO_BAR_API_URI")
      ENV.delete("GOVUK_APP_DOMAIN")
    end

    it "looks for an env variable matching the service name and returns its value when present" do
      ENV["PLEK_SERVICE_FOO_URI"] = "http://foo.localhost:5001"
      assert_equal "http://foo.localhost:5001", Plek.new().find("foo")
    end

    it "upcases and underscores the service name in the environment variable" do
      ENV["PLEK_SERVICE_FOO_API_URI"] = "http://foo.localhost:5001"
      assert_equal "http://foo.localhost:5001", Plek.new().find("foo-api")
    end

    it "upcases and underscores all hyphens in the service name in the environment variable" do
      ENV["PLEK_SERVICE_FOO_BAR_API_URI"] = "http://foo.localhost:5001"
      assert_equal "http://foo.localhost:5001", Plek.new().find("foo-bar-api")
    end

    it "falls back to regular behaviour when env variable is nil or empty" do
      ENV["GOVUK_APP_DOMAIN"] = "dev.gov.uk"
      ENV["PLEK_SERVICE_FOO_URI"] = nil
      ENV["PLEK_SERVICE_BAR_URI"] = ""

      assert_equal "http://foo.dev.gov.uk", Plek.new().find("foo")
      assert_equal "http://bar.dev.gov.uk", Plek.new().find("bar")
      assert_equal "http://baz.dev.gov.uk", Plek.new().find("baz") # not defined
    end

    it "ignores the force_http parameter" do
      ENV["PLEK_SERVICE_FOO_URI"] = "https://foo.localhost:5001"
      assert_equal "https://foo.localhost:5001", Plek.new().find("foo", :force_http => true)
    end
  end
end
