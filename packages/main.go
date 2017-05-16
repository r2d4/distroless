package main

import (
	"compress/gzip"
	"flag"
	"fmt"
	"io/ioutil"
	"os"

	"github.com/GoogleCloudPlatform/distroless/packages/parse"
)

var sourceFile = flag.String("source-file", "",
	"the file path of the packages.gz file")
var pkgName = flag.String("pkg-name", "",
	"the name of the package to search for")
var outputFile = flag.String("output-file", "", "")

func main() {
	flag.Parse()
	if *sourceFile == "" || *pkgName == "" || *outputFile == "" {
		flag.Usage()
		os.Exit(1)
	}

	r, err := os.Open(*sourceFile)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error opening packages file: %s", err)
		os.Exit(2)
	}
	defer r.Close()
	archive, err := gzip.NewReader(r)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error getting reader from gzip archive: %s", err)
		os.Exit(2)
	}
	defer archive.Close()
	packageList, err := ioutil.ReadAll(archive)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error reading gzip archive: %s", err)
		os.Exit(2)
	}

	metadata := parse.FindPackageMetadata(*pkgName, string(packageList))
	fmt.Println(metadata)
}
