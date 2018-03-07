package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"strconv"
)

func main() {
	b, err := ioutil.ReadFile("/Users/pmoore/x")
	if err != nil {
		panic(err)
	}
	fmt.Print(string(b))
	m := map[string]string{}
	err = json.Unmarshal(b, &m)
	if err != nil {
		panic(err)
	}
	fmt.Println("")
	fmt.Println("")
	for c := 0; c < 487; c++ {
		fmt.Print(m[strconv.Itoa(c)])
	}
	fmt.Println("")
}
