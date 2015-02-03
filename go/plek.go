package plek

import (
	"fmt"
	"net/url"
	"os"
	"strings"
)

// An EnvVarMissing is returned when a required environment variable is missing
type EnvVarMissing struct {
	// The environment variable this relates to
	EnvVar string
}

func (e *EnvVarMissing) Error() string {
	return "Expected " + e.EnvVar + " to be set. Perhaps you should run your task through govuk_setenv <appname>?"
}

// An EnvVarURLInvalid is returned when an environment variable does not
// contain a valid URL.
type EnvVarURLInvalid struct {
	// The environment variable this relates to
	EnvVar string
	// The error returned when parsing the URL.
	Err error
}

func (e *EnvVarURLInvalid) Error() string {
	return e.EnvVar + " " + e.Err.Error()
}

var httpDomains = map[string]bool{
	"dev.gov.uk": true,
}

// Find returns the base URL for the given service name in the default parent
// domain.  The default domain is taken from the GOVUK_APP_DOMAIN environment
// variable.  If this is unset, an EnvVarMissing error will be returned.
//
// The URLs for an individual service can be overridden by setting a
// corresponding PLEK_SERVICE_FOO_URI environment variable.  For example, to
// override the "foo-api" service url, set PLEK_SERVICE_FOO_API_URI to the base
// URL of the service.  If it can't be parsed by url.Parse, an EnvVarURLInvalid
// error will be returned.
func Find(hostname string) (*url.URL, error) {
	overrideURL, err := serviceURLFromEnvOverride(hostname)
	if err != nil {
		return nil, err
	}
	if overrideURL != nil {
		return overrideURL, nil
	}

	appDomain := os.Getenv("GOVUK_APP_DOMAIN")
	if appDomain == "" {
		return nil, &EnvVarMissing{EnvVar: "GOVUK_APP_DOMAIN"}
	}

	return Plek{parentDomain: appDomain}.Find(hostname), nil
}

// Plek builds service URLs for a given parent domain.
type Plek struct {
	parentDomain string
}

// New builds a new Plek instance for a given parent domain.
func New(parentDomain string) Plek {
	return Plek{parentDomain: parentDomain}
}

// Find returns the base URL for the given service name.
func (p Plek) Find(serviceName string) *url.URL {
	u := &url.URL{Scheme: "https", Host: serviceName + "." + p.parentDomain}
	if httpDomains[p.parentDomain] {
		u.Scheme = "http"
	}
	return u
}

// WebsiteRoot returns the public website base URL.  This is taken from the
// GOVUK_WEBSITE_ROOT environment variable.  If this is unset, an EnvVarMissing
// error will be returned.  If it can't be parsed by url.Parse, an
// EnvVarURLInvalid error will be returned.
func WebsiteRoot() (*url.URL, error) {
	return parseEnvVarURL("GOVUK_WEBSITE_ROOT")
}

// AssetRoot returns the public assets base URL. This is taken from the
// GOVUK_ASSET_ROOT environment variable.  If this is unset, an EnvVarMissing
// error will be returned.  If it can't be parsed by url.Parse, an
// EnvVarURLInvalid error will be returned.
func AssetRoot() (*url.URL, error) {
	return parseEnvVarURL("GOVUK_ASSET_ROOT")
}

func parseEnvVarURL(envVar string) (*url.URL, error) {
	urlString := os.Getenv(envVar)
	if urlString == "" {
		return nil, &EnvVarMissing{EnvVar: envVar}
	}
	u, err := url.Parse(urlString)
	if err != nil {
		return nil, &EnvVarURLInvalid{EnvVar: envVar, Err: err}
	}
	return u, nil
}

func serviceURLFromEnvOverride(serviceName string) (*url.URL, error) {
	varName := fmt.Sprintf(
		"PLEK_SERVICE_%s_URI",
		strings.ToUpper(strings.Replace(serviceName, "-", "_", -1)),
	)
	url, err := parseEnvVarURL(varName)
	if err != nil {
		if _, ok := err.(*EnvVarMissing); ok {
			return nil, nil
		}
		return nil, err
	}
	return url, nil
}
