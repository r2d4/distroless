package main

import (
	"flag"
	"fmt"
	"io"
	"io/ioutil"
	"net/http"
	"os"
)

var (
	url        = flag.String("url", "", "The url of the deb package repository")
	outputFile = flag.String("output-file", "", "The filepath to save Packages.gz to")
)

func main() {
	flag.Parse()
	if *url == "" || *outputFile == "" {
		flag.Usage()
		os.Exit(2)
	}

	if err := run(); err != nil {
		fmt.Fprint(os.Stderr, err)
		os.Exit(1)
	}
}

func run() error {

	r, err := http.Get(*url)
	if err != nil {
		return fmt.Errorf("Error getting Packages.gz file: %s\n", err)
	}
	defer r.Body.Close()

	if r.StatusCode != http.StatusOK {
		b, _ := ioutil.ReadAll(r.Body)
		return fmt.Errorf("Error getting Packages.gz: %s\n", string(b))
	}
	f, err := os.Create(*outputFile)
	if err != nil {
		return fmt.Errorf("Error opening output file: %s\n", err)
	}
	defer f.Close()

	_, err = io.Copy(f, r.Body)
	if err != nil {
		return fmt.Errorf("Error writing Packages.gz file: %s\n", err)
	}

	return nil
}
