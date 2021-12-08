package main

import (
	"crypto/tls"
	"crypto/x509"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"

	"github.com/lucas-clemente/quic-go/http3"
)

// ---------------------------------------------

type Client struct {
	certs        *x509.CertPool
	http3_client http.Client
}

func NewClient(CA_path string) Client {
	c := Client{
		certs: x509.NewCertPool(),
	}
	c.add_cert(CA_path)
	c.http3_client = http.Client{
		Transport: &http3.RoundTripper{
			TLSClientConfig: &tls.Config{
				RootCAs: c.certs,
			},
		},
	}
	return c
}

func (c *Client) read_cert(path string) []byte {
	file, err := os.Open(path)
	if err != nil {
		fmt.Println(err)
	}
	defer file.Close()
	fileinfo, err := file.Stat()
	if err != nil {
		fmt.Println(err)
	}

	filesize := fileinfo.Size()
	buffer := make([]byte, filesize)
	bytesread, err := file.Read(buffer)
	if (int64(bytesread) != filesize) || (err != nil) {
		fmt.Println(err)
	}

	return buffer
}

func (c *Client) add_cert(path string) {
	ok := c.certs.AppendCertsFromPEM(c.read_cert(path))
	if !ok {
		fmt.Println("Could not add certificate %s.", path)
	}
}

func (c *Client) Get(url string) (*http.Response, error) {
	return c.http3_client.Get(url)
}

// ---------------------------------------------
func main() {
	client := NewClient("CA.pem")
	resp, err := client.Get("http://10.3.0.2")
	if err != nil {
		fmt.Println(err)
	}
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	fmt.Println(string(body))
}
