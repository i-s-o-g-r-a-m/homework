package main

/*
Even though this only provided me with a small taste of golang, I have to say
that, coming from a mainly-Python background, it was a lot of fun having a
compile step that did some type checking -- so much fun, in fact, that
I was able to overlook gofmt's preference for tabs over spaces :-)
*/

import (
	"crypto/sha1"
	"flag"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/http/httptest"
	"sort"
	"strconv"
	"strings"
)

const (
	crlf       = "\r\n"
	colonspace = ": "
)

// returns a response's http headers sorted lexicographically
func sortedHeaders(w *httptest.ResponseRecorder) []string {
	headers := []string{}
	for k := range w.Header() {
		headers = append(headers, k)
	}
	sort.Strings(headers)
	return headers
}

// computes an sha1 hash to be used as a checksum for the provided http response
func computeResponseChecksum(w *httptest.ResponseRecorder) string {
	// this function is kind of ugly; I'd prefer to build up the hash
	// in a more declarative and maybe less procedural way

	headers := sortedHeaders(w)
	hasher := sha1.New()

	io.WriteString(hasher, strconv.Itoa(w.Code))
	io.WriteString(hasher, crlf)

	for _, header := range headers {
		io.WriteString(hasher, header)
		io.WriteString(hasher, colonspace)
		io.WriteString(hasher, w.Header().Get(header))
		io.WriteString(hasher, crlf)
	}

	io.WriteString(hasher, "X-Checksum-Headers: ")
	io.WriteString(hasher, strings.Join(headers, ";"))
	io.WriteString(hasher, crlf)
	io.WriteString(hasher, crlf)
	io.WriteString(hasher, w.Body.String())

	return fmt.Sprintf("%x", hasher.Sum(nil))
}

// adds an 'X-Checksum' header to the response
func ChecksumMiddleware(h http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// FWIW I discovered ResponseRecorder via googling, not the README hint ;-)
		rec := httptest.NewRecorder()
		h.ServeHTTP(rec, r)
		w.Header().Set("X-Checksum", computeResponseChecksum(rec))
		h.ServeHTTP(w, r)
	})
}

// Do not change this function.
func main() {
	var listenAddr = flag.String("http", ":8080", "address to listen on for HTTP")
	flag.Parse()

	http.Handle("/", ChecksumMiddleware(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("X-Foo", "bar")
		w.Header().Set("Content-Type", "text/plain")
		w.Header().Set("Date", "Sun, 08 May 2016 14:04:53 GMT")
		msg := "Curiosity is insubordination in its purest form.\n"
		w.Header().Set("Content-Length", strconv.Itoa(len(msg)))
		fmt.Fprintf(w, msg)
	})))

	log.Fatal(http.ListenAndServe(*listenAddr, nil))
}
