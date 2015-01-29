package plek

import "net/url"

var httpDomains = map[string]bool{
	"dev.gov.uk": true,
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
