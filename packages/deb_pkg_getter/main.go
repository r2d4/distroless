package main

import (
	"compress/gzip"
	"flag"
	"fmt"
	"io"
	"io/ioutil"
	"os"

	"net/http"

	"github.com/GoogleCloudPlatform/distroless/packages/deb_pkg_getter/parse"
)

var (
	sourceFile = flag.String("source-file", "", "the file path of the packages.gz file")
	pkgName    = flag.String("pkg-name", "", "the name of the package to search for")
	sourceURL  = flag.String("source-url", "", "the base url for the packages mirror")
	outputFile = flag.String("output-file", "", "the output file for the deb package")
)

func main() {
	flag.Parse()
	if *sourceFile == "" || *pkgName == "" || *outputFile == "" || *sourceURL == "" {
		flag.Usage()
		os.Exit(2)
	}

	if err := run(); err != nil {
		fmt.Fprint(os.Stderr, err)
		os.Exit(1)
	}
}

func run() error {
	r, err := os.Open(*sourceFile)
	if err != nil {
		return fmt.Errorf("Error opening packages file: %s\n", err)
	}
	defer r.Close()

	archive, err := gzip.NewReader(r)
	if err != nil {
		return fmt.Errorf("Error getting reader from gzip archive: %s\n", err)
	}
	defer archive.Close()

	packageList, err := ioutil.ReadAll(archive)
	if err != nil {
		return fmt.Errorf("Error reading gzip archive: %s\n", err)
	}

	url := parse.GetPackageURL(*pkgName, string(packageList), *sourceURL)
	if url == "" {
		return fmt.Errorf("Error getting deb %s from %s\n", *pkgName, *sourceURL)
	}

	debResp, err := http.Get(url)
	if err != nil {
		return fmt.Errorf("Error fetch deb: %s\n", err)
	}
	if debResp.StatusCode != http.StatusOK {
		b, _ := ioutil.ReadAll(debResp.Body)
		return fmt.Errorf("Error getting Packages.gz: %s", string(b))
	}

	f, err := os.Create(*outputFile)
	if err != nil {
		return fmt.Errorf("Error opening output file: %s\n", err)
	}
	defer f.Close()

	_, err = io.Copy(f, debResp.Body)
	if err != nil {
		return fmt.Errorf("Error writing %s file: %s\n", *outputFile, err)
	}

	return nil
}
