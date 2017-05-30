package main //import "github.com/GoogleCloudPlatform/distroless/packages/deb_pkg"

import (
	"compress/gzip"
	"flag"
	"fmt"
	"io"
	"io/ioutil"
	"os"

	"net/http"

	"github.com/GoogleCloudPlatform/distroless/packages/deb_pkg/parse"
)

var (
	fetchPackageList = flag.Bool("fetch-package-list", false, "if true, only fetch the package list")
	fetchPackage     = flag.Bool("fetch-package", false, "if true, fetch the package specified by pkg-name")

	sourceFile = flag.String("source-file", "", "the file path of the packages.gz file")
	pkgName    = flag.String("pkg-name", "", "the name of the package to search for")
	sourceURL  = flag.String("source-url", "", "the base url for the packages mirror")
	outputFile = flag.String("output-file", "", "the output file to write")
)

func main() {
	flag.Parse()
	if *fetchPackageList == *fetchPackage {
		fmt.Fprintf(os.Stderr, "Only one of fetch-package-list and fetch-package may be specified")
		flag.Usage()
		os.Exit(2)
	}

	if *fetchPackageList {
		if *sourceURL == "" || *outputFile == "" {
			flag.Usage()
			os.Exit(2)
		}
		if err := downloadToFile(*sourceURL, *outputFile); err != nil {
			fmt.Fprint(os.Stderr, err)
			os.Exit(1)
		}
	}

	if *fetchPackage {
		if *sourceFile == "" || *pkgName == "" || *outputFile == "" || *sourceURL == "" {
			flag.Usage()
			os.Exit(2)
		}
		if err := getPackage(*sourceFile, *pkgName, *outputFile, *sourceURL); err != nil {
			fmt.Fprint(os.Stderr, err)
			os.Exit(1)
		}
	}
}

// getPackage parses the Packages.gz file at sourceFile and downloads pkgName to outputFile
func getPackage(sourceFile, pkgName, outputFile, sourceURL string) error {
	r, err := os.Open(sourceFile)
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

	url := parse.GetPackageURL(pkgName, string(packageList), sourceURL)
	if url == "" {
		return fmt.Errorf("Error getting deb %s from %s\n", pkgName, sourceURL)
	}

	return downloadToFile(url, outputFile)
}

func downloadToFile(srcURL, dest string) error {
	r, err := http.Get(srcURL)
	if err != nil {
		return fmt.Errorf("Error downloading file: %s\n", err)
	}
	defer r.Body.Close()

	if r.StatusCode != http.StatusOK {
		b, _ := ioutil.ReadAll(r.Body)
		return fmt.Errorf("Error non 200 status code from downloading %s\n", string(b))
	}
	f, err := os.Create(dest)
	if err != nil {
		return fmt.Errorf("Error opening output file: %s\n", err)
	}
	defer f.Close()

	_, err = io.Copy(f, r.Body)
	if err != nil {
		return fmt.Errorf("Error writing file: %s\n", err)
	}

	return nil
}
