package plek

import (
	"net/url"
	"os"
	"strings"
)

type EnvVarMissing struct {
	EnvVar string
}

func (e *EnvVarMissing) Error() string {
	return "Expected " + e.EnvVar + " to be set. Perhaps you should run your task through govuk_setenv <appname>?"
}

type EnvVarURLInvalid struct {
	EnvVar string
	Err    error
}

func (e *EnvVarURLInvalid) Error() string {
	return e.EnvVar + " " + e.Err.Error()
}

var httpDomains = map[string]bool{
	"dev.gov.uk": true,
}

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

type Plek struct {
	parentDomain string
}

func New(parentDomain string) Plek {
	return Plek{parentDomain: parentDomain}
}

func (p Plek) Find(serviceName string) *url.URL {
	u := &url.URL{Scheme: "https", Host: serviceName + "." + p.parentDomain}
	if httpDomains[p.parentDomain] {
		u.Scheme = "http"
	}
	return u
}

func WebsiteRoot() (*url.URL, error) {
	return parseEnvVarURL("GOVUK_WEBSITE_ROOT")
}

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
	varName := "PLEK_SERVICE_" + strings.ToUpper(strings.Replace(serviceName, "-", "_", -1)) + "_URI"
	url, err := parseEnvVarURL(varName)
	if err != nil {
		if _, ok := err.(*EnvVarMissing); ok {
			return nil, nil
		}
		return nil, err
	}
	return url, nil
}
