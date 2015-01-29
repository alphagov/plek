package plek

import (
	"net/url"
	"os"
	"testing"
)

type FindExample struct {
	ParentDomain string
	ServiceName  string
	ExpectedURL  string
}

var findExamples = []FindExample{
	{
		ParentDomain: "example.com",
		ServiceName:  "foo",
		ExpectedURL:  "https://foo.example.com",
	},
	{
		ParentDomain: "example.com",
		ServiceName:  "foo.bar",
		ExpectedURL:  "https://foo.bar.example.com",
	},
	{ // dev.gov.uk domains should magically return http
		ParentDomain: "dev.gov.uk",
		ServiceName:  "foo",
		ExpectedURL:  "http://foo.dev.gov.uk",
	},
}

func TestFind(t *testing.T) {
	for i, ex := range findExamples {
		testFind(t, i, ex)
	}
}

func testFind(t *testing.T, i int, ex FindExample) {
	actual := New(ex.ParentDomain).Find(ex.ServiceName)
	expected, _ := url.Parse(ex.ExpectedURL)
	if *actual != *expected {
		t.Errorf("Example %d: expected %s, got %s", i, expected.String(), actual.String())
	}
}

type PackageFindExample struct {
	GovukAppDomain string
	ServiceName    string
	ExpectedURL    string
	ExpectError    bool
}

var packageFindExamples = []PackageFindExample{
	{
		GovukAppDomain: "example.com",
		ServiceName:    "foo",
		ExpectedURL:    "https://foo.example.com",
	},
	{
		GovukAppDomain: "",
		ServiceName:    "anything",
		ExpectError:    true,
	},
}

func TestPackageFind(t *testing.T) {
	for i, ex := range packageFindExamples {
		testPackageFind(t, i, ex)
	}
}

func testPackageFind(t *testing.T, i int, ex PackageFindExample) {
	os.Clearenv()
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
