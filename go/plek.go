package plek

import (
	"fmt"
	"net/url"
	"os"
	"strings"
)

const devDomain = "dev.gov.uk"

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
	devDomain: true,
}

// Find returns the base URL for the given service name in the default parent
// domain. The domain is taken from the GOVUK_APP_DOMAIN environment variable.
// If this is unset, "dev.gov.uk" is used.
//
// The URLs for an individual service can be overridden by setting a
// corresponding PLEK_SERVICE_FOO_URI environment variable.  For example, to
// override the "foo-api" service url, set PLEK_SERVICE_FOO_API_URI to the base
// URL of the service.
func Find(hostname string) string {
	overrideURL := serviceURLFromEnvOverride(hostname)
	if overrideURL != "" {
		return overrideURL
	}

	appDomain := os.Getenv("GOVUK_APP_DOMAIN")
	if appDomain == "" {
		if devDomainFromEnv := os.Getenv("DEV_DOMAIN"); devDomainFromEnv != "" {
			appDomain = devDomainFromEnv
		} else {
			appDomain = devDomain
		}
	}

	return Plek{parentDomain: appDomain}.Find(hostname)
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
func (p Plek) Find(serviceName string) string {
	u := &url.URL{Scheme: "https", Host: serviceName + "." + p.parentDomain}
	if httpDomains[p.parentDomain] {
		u.Scheme = "http"
	}
	return u.String()
}

// WebsiteRoot returns the public website base URL.  This is taken from the
// GOVUK_WEBSITE_ROOT environment variable.  If this is unset, an EnvVarMissing
// error will be returned.
func WebsiteRoot() (string, error) {
	return readEnvVarURL("GOVUK_WEBSITE_ROOT")
}

// AssetRoot returns the public assets base URL. This is taken from the
// GOVUK_ASSET_ROOT environment variable.  If this is unset, an EnvVarMissing
// error will be returned.
func AssetRoot() (string, error) {
	return readEnvVarURL("GOVUK_ASSET_ROOT")
}

func readEnvVarURL(envVar string) (string, error) {
	urlString := os.Getenv(envVar)
	if urlString == "" {
		return "", &EnvVarMissing{EnvVar: envVar}
	}
	return urlString, nil
}

func serviceURLFromEnvOverride(serviceName string) string {
	varName := fmt.Sprintf(
		"PLEK_SERVICE_%s_URI",
		strings.ToUpper(strings.Replace(serviceName, "-", "_", -1)),
	)
	urlString, err := readEnvVarURL(varName)
	if err != nil {
		// it has to be EnvVarMissing
		return ""
	}
	return urlString
}
