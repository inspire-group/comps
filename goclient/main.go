package main

import (
	"bytes"
  "flag"
	"crypto/tls"
	"io"
	"log"
	"net/http"
	"sync"

	"github.com/lucas-clemente/quic-go"
	"github.com/lucas-clemente/quic-go/http3"
)

// based off of https://github.com/lucas-clemente/quic-go/blob/master/example/client/main.go
func main() {
  nRequests := flag.Int("n", 1, "how many times to request each resource")
  flag.Parse()
  urls := flag.Args()

  var qconf quic.Config
	roundTripper := &http3.RoundTripper{
		TLSClientConfig: &tls.Config{
			InsecureSkipVerify: true,
		},
		QuicConfig: &qconf,
	}


	defer roundTripper.Close()
	hclient := &http.Client{
		Transport: roundTripper,
	}

	var wg sync.WaitGroup
	wg.Add(len(urls)*(*nRequests))
	for _, addr := range urls {
    for i := 0; i < *nRequests; i++ {
		  log.Printf("GET %s", addr)
		  go func(addr string) {
		  	rsp, err := hclient.Get(addr)
		  	if err != nil {
		  		log.Fatal(err)
		  	}
		  	log.Printf("Got response for %s: %#v", addr, rsp)
		  	body := &bytes.Buffer{}
		  	_, err = io.Copy(body, rsp.Body)
		  	if err != nil {
		  		log.Fatal(err)
		  	}
		  	log.Printf("Request Body:")
  	  	log.Printf("%s", body.Bytes())
		  	wg.Done()
		  }(addr)
    }
	}
	wg.Wait()
}

