package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net"
	"os"
)

type Config struct {
	AccessToken                string `json:"access_token"`
	ClientId                   string `json:"client_id"`
	Certificate                string `json:"certificate"`
	WorkerGroup                string `json:"worker_group"`
	WorkerId                   string `json:"worker_id"`
	WorkerType                 string `json:"worker_type"`
	ProvisionerId              string `json:"provisioner_id"`
	RefreshUrlsPrematurelySecs int    `json:"refresh_urls_prematurely_secs"`
	Debug                      string `json:"debug"`
	LiveLogExecutable          string `json:"livelog_executable"`
	LiveLogSecret              string `json:"livelog_secret"`
	PublicIP                   net.IP `json:"public_ip"`
	SubDomain                  string `json:"subdomain"`
}

func main() {
	data := Config{AccessToken: "*****", ClientId: "*****", Certificate: "*****", WorkerGroup: "*****", WorkerId: "*****", WorkerType: "*****", ProvisionerId: "*****", RefreshUrlsPrematurelySecs: 310, Debug: "*****", LiveLogExecutable: "*****", LiveLogSecret: "*****", PublicIP: net.IP{0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0xff, 0xff, 0x34, 0x20, 0x5d, 0xad}, SubDomain: "*****"}
	b, err := json.Marshal(data)
	if err != nil {
		panic(err)
	}
	var out bytes.Buffer
	json.Indent(&out, b, "", "    ")
	out.WriteTo(os.Stdout)
	fmt.Println()
}
