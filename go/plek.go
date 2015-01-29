package plek

import (
	"errors"
	"net/url"
	"os"
)

var MissingGOVUKAppDomain = errors.New("Expected GOVUK_APP_DOMAIN to be set. Perhaps you should run your task through govuk_setenv <appname>?")

var httpDomains = map[string]bool{
	"dev.gov.uk": true,
}

func Find(hostname string) (*url.URL, error) {
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
