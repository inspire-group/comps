package main

import (
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/lucas-clemente/quic-go/http3"
)

func ClientHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Add("Content-Type", "application/json")
	resp, _ := json.Marshal(map[string]string{
		"ip": GetIP(r),
	})
	w.Write(resp)
	fmt.Println(string(resp))
}

func GetIP(r *http.Request) string {
	forwarded := r.Header.Get("X-FORWARDED-FOR")
	if forwarded != "" {
		fmt.Println("Forwarded!")
		return forwarded
	}
	return r.RemoteAddr
}

func main() {
	// http.Handle("/", http.FileServer(http.Dir("site")))
	http.HandleFunc("/", ClientHandler)
	err := http3.ListenAndServeQUIC("0.0.0.0:443", "/server/tls/server.crt", "/server/tls/server.key", nil)
	if err != nil {
		panic(err)
	}
}
