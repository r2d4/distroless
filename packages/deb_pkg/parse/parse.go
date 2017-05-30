package parse //import "github.com/GoogleCloudPlatform/distroless/packages/deb_pkg/parse"

import "strings"

const (
	pkgKey      = "Package"
	filenameKey = "Filename"
)

func FindPackageMetadata(pkgName string, packageList string) map[string]string {
	metadata := map[string]string{}
	found := false

	lines := strings.Split(packageList, "\n")
	for _, line := range lines {
		if line != "" {
			if strings.Contains(line, ":") {
				kv := strings.SplitN(line, ":", 2)
				key := strings.TrimSpace(kv[0])
				value := strings.TrimSpace(kv[1])
				if key == pkgKey && value == pkgName {
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

func GetPackageURL(pkgName, packageList, source string) string {
	metadata := FindPackageMetadata(pkgName, packageList)

	fpath, found := metadata[filenameKey]
	if !found {
		return ""
	}

	return source + "/debian/" + strings.TrimSpace(fpath)
}
