package main

import (
	"compress/gzip"
	"flag"
	"fmt"
	"io/ioutil"
	"os"
	"strings"
)

var sourceFile = flag.String("source-file", "",
	"the file path of the packages.gz file")
var pkgName = flag.String("pkg-name", "",
	"the name of the package to search for")
var outputFile = flag.String("output-file", "", "")

func main() {
	wd, _ := os.Getwd()

	infos, _ := ioutil.ReadDir(wd)
	for _, info := range infos {
		fmt.Println(info.Name())
	}

	fmt.Println(wd)

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

	metadata := findPackageMetadata(*pkgName, string(packageList))
	fmt.Println(metadata)
}

func findPackageMetadata(pkgName string, packageList string) map[string]string {
	metadata := map[string]string{}
	found := false

	lines := strings.Split(packageList, "\n")
	for _, line := range lines {
		if line != "" {
			if strings.Contains(line, ":") {
				kv := strings.SplitN(line, ":", 2)
				if kv[0] == pkgName {
					found = true
				}
				metadata[kv[0]] = kv[1]
			}
		} else {
			if found {
				return metadata
			}
		}
	}

	return nil
}
