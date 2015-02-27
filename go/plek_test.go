package plek

import (
	"net/url"
	"os"
	"testing"
)

type FindExample struct {
	GovukAppDomain string
	ServiceName    string
	ExpectedURL    string
	ExpectError    bool
	Environ        map[string]string
}

var findExamples = []FindExample{
	{
		GovukAppDomain: "example.com",
		ServiceName:    "foo",
		ExpectedURL:    "https://foo.example.com",
	},
	{
		GovukAppDomain: "example.com",
		ServiceName:    "foo.bar",
		ExpectedURL:    "https://foo.bar.example.com",
	},
	{ // dev.gov.uk domains should magically return http
		GovukAppDomain: "dev.gov.uk",
		ServiceName:    "foo",
		ExpectedURL:    "http://foo.dev.gov.uk",
	},
}

func TestFind(t *testing.T) {
	for i, ex := range findExamples {
		testFind(t, i, ex)
	}
}

func testFind(t *testing.T, i int, ex FindExample) {
	actual := New(ex.GovukAppDomain).Find(ex.ServiceName)
	expected, _ := url.Parse(ex.ExpectedURL)
	if *actual != *expected {
		t.Errorf("Example %d: expected %s, got %s", i, expected.String(), actual.String())
	}
}

var packageFindExamples = []FindExample{
	{
		GovukAppDomain: "example.com",
		ServiceName:    "foo",
		ExpectedURL:    "https://foo.example.com",
	},
	{
		GovukAppDomain: "",
		ServiceName:    "foo",
		ExpectedURL:    "http://foo.dev.gov.uk",
	},
	// Overriding a specific service URL with an ENV var.
	{
		GovukAppDomain: "foo.com",
		ServiceName:    "foo",
		ExpectedURL:    "http://foo.example.com",
		Environ:        map[string]string{"PLEK_SERVICE_FOO_URI": "http://foo.example.com"},
	},
	{
		GovukAppDomain: "foo.com",
		ServiceName:    "foo-bar",
		ExpectedURL:    "http://anything.example.com",
		Environ:        map[string]string{"PLEK_SERVICE_FOO_BAR_URI": "http://anything.example.com"},
	},
	{
		GovukAppDomain: "", // Should not be required when using overrides
		ServiceName:    "foo",
		ExpectedURL:    "http://foo.example.com",
		Environ:        map[string]string{"PLEK_SERVICE_FOO_URI": "http://foo.example.com"},
	},
	{
		ServiceName: "foo",
		ExpectError: true,
		Environ:     map[string]string{"PLEK_SERVICE_FOO_URI": "http://invalid%hostname.com"},
	},
}

func TestPackageFind(t *testing.T) {
	for i, ex := range packageFindExamples {
		testPackageFind(t, i, ex)
	}
}

func testPackageFind(t *testing.T, i int, ex FindExample) {
	os.Clearenv()
	for k, v := range ex.Environ {
		os.Setenv(k, v)
	}
	os.Setenv("GOVUK_APP_DOMAIN", ex.GovukAppDomain)

	actual, err := Find(ex.ServiceName)
	if ex.ExpectError {
		if err == nil {
			t.Errorf("Example %d: Expected error, received none", i)
		}
		return
	}
	if err != nil {
		t.Errorf("Example %d: received unexpected error %v", i, err)
		return
	}
	expected, _ := url.Parse(ex.ExpectedURL)
	if *actual != *expected {
		t.Errorf("Example %d: expected %s, got %s", i, expected.String(), actual.String())
	}
}

func TestWebsiteRoot(t *testing.T) {
	os.Clearenv()
	os.Setenv("GOVUK_WEBSITE_ROOT", "https://www.gov.uk")

	actual, err := WebsiteRoot()
	if err != nil {
		t.Fatalf("Received unexpected error %v", err)
	}
	expected, _ := url.Parse("https://www.gov.uk")
	if *actual != *expected {
		t.Errorf("Expected %s, got %s", expected.String(), actual.String())
	}
}

func TestWebsiteRootMissing(t *testing.T) {
	os.Clearenv()

	_, err := WebsiteRoot()
	if err == nil {
		t.Fatal("Expected error, received none")
	}
	errMissing, ok := err.(*EnvVarMissing)
	if !ok {
		t.Fatalf("Expected error to be a *EnvVarMissing, got %T", err)
	}
	if errMissing.EnvVar != "GOVUK_WEBSITE_ROOT" {
		t.Errorf("Expected error relating to GOVUK_WEBSITE_ROOT, got %s", errMissing.EnvVar)
	}
}

func TestWebsiteRootInvalid(t *testing.T) {
	os.Clearenv()
	os.Setenv("GOVUK_WEBSITE_ROOT", "https://invalid%hostname.com")

	_, err := WebsiteRoot()
	if err == nil {
		t.Fatal("Expected error, received none")
	}
	errInvalid, ok := err.(*EnvVarURLInvalid)
	if !ok {
		t.Fatalf("Expected error to be a *EnvVarURLInvalid, got %T", err)
	}
	if errInvalid.EnvVar != "GOVUK_WEBSITE_ROOT" {
		t.Errorf("Expected error relating to GOVUK_WEBSITE_ROOT, got %s", errInvalid.EnvVar)
	}
}

func TestAssetRoot(t *testing.T) {
	os.Clearenv()
	os.Setenv("GOVUK_ASSET_ROOT", "https://www.gov.uk")

	actual, err := AssetRoot()
	if err != nil {
		t.Fatalf("Received unexpected error %v", err)
	}
	expected, _ := url.Parse("https://www.gov.uk")
	if *actual != *expected {
		t.Errorf("Expected %s, got %s", expected.String(), actual.String())
	}
}

func TestAssetRootMissing(t *testing.T) {
	os.Clearenv()

	_, err := AssetRoot()
	if err == nil {
		t.Fatal("Expected error, received none")
	}
	errMissing, ok := err.(*EnvVarMissing)
	if !ok {
		t.Fatalf("Expected error to be a *EnvVarMissing, got %T", err)
	}
	if errMissing.EnvVar != "GOVUK_ASSET_ROOT" {
		t.Errorf("Expected error relating to GOVUK_ASSET_ROOT, got %s", errMissing.EnvVar)
	}
}

func TestAssetRootInvalid(t *testing.T) {
	os.Clearenv()
	os.Setenv("GOVUK_ASSET_ROOT", "https://invalid%hostname.com")

	_, err := AssetRoot()
	if err == nil {
		t.Fatal("Expected error, received none")
	}
	errInvalid, ok := err.(*EnvVarURLInvalid)
	if !ok {
		t.Fatalf("Expected error to be a *EnvVarURLInvalid, got %T", err)
	}
	if errInvalid.EnvVar != "GOVUK_ASSET_ROOT" {
		t.Errorf("Expected error relating to GOVUK_ASSET_ROOT, got %s", errInvalid.EnvVar)
	}
}
