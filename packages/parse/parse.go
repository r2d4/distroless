package parse

import "strings"

func FindPackageMetadata(pkgName string, packageList string) map[string]string {
	metadata := map[string]string{}
	found := false

	lines := strings.Split(packageList, "\n")
	for _, line := range lines {
		if line != "" {
			if strings.Contains(line, ":") {
				kv := strings.SplitN(line, ":", 2)
				if strings.TrimSpace(kv[0]) == pkgName {
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
