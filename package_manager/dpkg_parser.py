import argparse
import gzip
import re
import io
import urllib2
import json

PACKAGES_FILE_NAME = "file/Packages.json"
DEB_FILE_NAME = "pkg.deb"

parser = argparse.ArgumentParser(
    description = "Downloads a deb package from a package source file"
)

parser.add_argument("--packages-file", action='store',
                    help='The file path of the Packages.gz file')
parser.add_argument("--package-name", action='store',
                    help='The name of the package to search for and download')

parser.add_argument("--download-and-extract-only", action='store',
                    help='If True, download Packages.gz and make urls absolute from mirror url')
parser.add_argument("--mirror-url", action='store',
                    help='The base url for the package list mirror')
parser.add_argument("--arch", action='store',
                    help='The target architecture for the package list')
parser.add_argument("--distro", action='store',
                    help='The target distribution for the package list')

def main():
    args = parser.parse_args()
    if args.download_and_extract_only:
        download_package_list(args.mirror_url, args.distro, args.arch)
    else:
        download_dpkg(args.packages_file, args.package_name)


def download_dpkg(packages_file, package_name):
    with open(packages_file, 'rb') as f:
        metadata = json.load(f)
    for pkg in metadata:
        if pkg["Package"] == package_name:
            print(pkg)
            buf = urllib2.urlopen(pkg["Filename"])
            with open(DEB_FILE_NAME, 'w') as f:
                f.write(buf.read())
            break

def download_package_list(mirror_url, distro, arch):
    url = "%s/debian/dists/%s/main/binary-%s/Packages.gz" % (
        mirror_url,
        distro,
        arch
    )
    print(url)
    buf = urllib2.urlopen(url)
    f = gzip.GzipFile(fileobj=io.BytesIO(buf.read()))
    data = f.read()
    metadata = parse_package_metadata(data, ":")
    for pkg in metadata:
        pkg["Filename"] = mirror_url + "/debian/" + pkg["Filename"]
    with open(PACKAGES_FILE_NAME, 'w') as f:
        json.dump(metadata, f)
 
def parse_package_metadata(data, separator):
    metadata = []
    found = False

    raw_entries = [line.rstrip() for line in data.splitlines()]
    parsed_entries = []
    current_key = None
    current_entry = {}

    for line in raw_entries:
        if line:
            if re.match(r'\s', line):
                #If the line starts with indentation,
                #it is a continuation of the previous key
                if current_entry is None or current_key is None:
                    raise Exception("Found incorrect indention on line:" + line)
                current_entry[current_key] += line.strip()
            elif separator in line:
                (key, value) = line.split(separator, 1)
                current_key = key.strip()
                if current_key in current_entry:
                    raise Exception("Duplicate key for package metadata:" + current_key + "\n" + current_entry)
                current_entry[current_key] = value.strip()
            else:
                raise Exception("Valid line, but no delimiter or indentation:" + line)
        else:
            if current_entry:
                parsed_entries.append(current_entry)
            current_entry = {}
            current_key = None
    if current_entry:
        parsed_entries.append(current_entry)
    return parsed_entries
            
if __name__ == "__main__":
    main()
