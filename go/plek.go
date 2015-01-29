package plek

import (
	"errors"
	"net/url"
	"os"
	"strings"
)

var MissingGOVUKAppDomain = errors.New("Expected GOVUK_APP_DOMAIN to be set. Perhaps you should run your task through govuk_setenv <appname>?")

type EnvURLError struct {
	EnvVar string
	Err    error
}

func (e *EnvURLError) Error() string {
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
		return nil, MissingGOVUKAppDomain
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

func serviceURLFromEnvOverride(serviceName string) (*url.URL, error) {
	varName := "PLEK_SERVICE_" + strings.ToUpper(strings.Replace(serviceName, "-", "_", -1)) + "_URI"
	urlStr := os.Getenv(varName)
	if urlStr == "" {
		return nil, nil
	}
	u, err := url.Parse(urlStr)
	if err != nil {
		return nil, &EnvURLError{EnvVar: varName, Err: err}
	}
	return u, nil
}
