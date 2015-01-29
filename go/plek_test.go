package plek

import (
	"net/url"
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
