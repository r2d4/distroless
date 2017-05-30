package parse //import "github.com/GoogleCloudPlatform/distroless/packages/deb_pkg/parse"

import (
	"io/ioutil"
	"testing"
)

func TestGetPackageURL(t *testing.T) {
	f, _ := ioutil.ReadFile("testdata/Packages")

	pkgList := string(f)
	pkgMap := map[string]string{
		"ca-certificates": "http://debian.org/debian/pool/main/c/ca-certificates/ca-certificates_20141019+deb8u3_all.deb",
	}

	for pkgName, expectedPath := range pkgMap {
		foundPath := GetPackageURL(pkgName, pkgList, "http://debian.org")
		if foundPath != expectedPath {
			t.Fatalf("Wrong filepath, got %s, expected %s", foundPath, expectedPath)
		}
	}
}
