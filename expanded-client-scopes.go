package main

import (
	"log"
	"os"
	"strings"

	"github.com/taskcluster/taskcluster-client-go/auth"
	"github.com/taskcluster/taskcluster-client-go/tcclient"
)

func main() {
	myAuth := auth.New(
		&tcclient.Credentials{
			ClientId:    os.Getenv("TASKCLUSTER_CLIENT_ID"),
			AccessToken: os.Getenv("TASKCLUSTER_ACCESS_TOKEN"),
			Certificate: os.Getenv("TASKCLUSTER_CERTIFICATE"),
		},
	)
	cl, _, err := myAuth.ListClients("")
	if err != nil {
		log.Fatalf("Could not list clients: '%v'", err)
	}
	for _, c := range *cl {
		log.Printf("Client: '%v'", c.ClientID)
		log.Print("Scopes:")
		for _, s := range c.ExpandedScopes {
			if strings.HasSuffix(s, ":*") && strings.Index(s, ":") == len(s)-2 {
				log.Print("    " + s)
			}
		}
	}
}
