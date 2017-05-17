package parse

import (
	"fmt"
	"io/ioutil"
	"testing"
)

func TestFindPackageMetadata(t *testing.T) {
	f, _ := ioutil.ReadFile("testdata/Packages")
	pkgList := string(f)
	metadata := FindPackageMetadata("ca-certificates", pkgList)
	fmt.Println(metadata)
	url, ok := metadata["File"]
	if !ok {
		t.Fatalf("Url was none: %s", url)
	}
}
