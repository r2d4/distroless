# Copyright 2017 Google Inc. All rights reserved.

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import argparse
import gzip
import io
import urllib2
import json

import re

from os import path


from package_manager.parse_metadata import parse_package_metadata

PACKAGES_FILE_NAME = "file/Packages.json"
BAZEL_PKG_DICT_FILE = "file/packages.bzl"
FILENAME_KEY = "Filename"

parser = argparse.ArgumentParser(
    description="Downloads a deb package from a package source file"
)

parser.add_argument("--package-files", action='store',
                    help='A list of Packages.gz files to use')
parser.add_argument("--packages", action='store',
                    help='A comma delimited list of packages to search for and download')
parser.add_argument("--bazel-rule-name", action='store',
                    help="The name of the bazel rule")

parser.add_argument("--download-and-extract-only", action='store',
                    help='If True, download Packages.gz and make urls absolute from mirror url')
parser.add_argument("--mirror-url", action='store',
                    help='The base url for the package list mirror')
parser.add_argument("--arch", action='store',
                    help='The target architecture for the package list')
parser.add_argument("--distro", action='store',
                    help='The target distribution for the package list')

parser.add_argument("--bazel-compatible-names", action='store',
                    help='If True, rename package names to valid Bazel label names')

def main():
    """ A tool for downloading debian packages and package metadata """
    args = parser.parse_args()
    if args.download_and_extract_only:
        download_package_list(args.mirror_url, args.distro, args.arch)
    else:
        download_dpkg(args.package_files, args.packages, args.bazel_compatible_names, args.bazel_rule_name)


def download_dpkg(package_files, packages, bazel_compatible_names, bazel_rule_name):
    """ Using an unzipped, json package file with full urls,
     downloads a .deb package

    Uses the 'Filename' key to download the .deb package
    """
    bazel_pkg_dict = {}
    for pkg_name in packages.split(","):
        found = False
        for package_file in package_files.split(","):
            with open(package_file, 'rb') as f:
                metadata = json.load(f)
            if pkg_name in metadata:
                pkg = metadata[pkg_name]
                buf = urllib2.urlopen(pkg[FILENAME_KEY])
                if bazel_compatible_names:
                    bazel_pkg_dict[pkg_name] = "@" + bazel_rule_name + ":file/" + bazel_compatible_name(pkg_name) + ".deb"
                with open(path.join("file", pkg_name + ".deb"), 'w') as f:
                    f.write(buf.read())
                found = True
                break
        if not found:
            raise Exception("Package %s not found in any of the sources" % pkg_name)
    with open(BAZEL_PKG_DICT_FILE, 'w') as f:
        f.write("packages = ") 
        f.write(json.dumps(bazel_pkg_dict))

def bazel_compatible_name(package_name):
    """Returns to a bazel label compatible string

    Bazel package names may contain only
        A-Z, a-z, 0-9, '/', '-', '.', ' ', '$', '(', ')' and '_'.

    """
    old_package_name = package_name
    package_name = re.sub(r"[^A-Za-z0-9/\-\. \$\(\)_]", "_", package_name)
    if package_name != old_package_name:
        print("Warning: Package name rewritten as %s from %s to satisfy bazel label name restrictions" % (package_name, old_package_name))
    return package_name

def download_package_list(mirror_url, distro, arch):
    """Downloads a debian package list, expands the relative urls,
    and saves the metadata as a json file

    A debian package list is a gzipped, newline delimited, colon separated
    file with metadata about all the packages available in that repository.
    Multiline keys are indented with spaces.

    An example package looks like:

Package: newmail
Version: 0.5-2
Installed-Size: 76
Maintainer: Martin Schulze <joey@debian.org>
Architecture: amd64
Depends: libc6 (>= 2.7-1)
Description: Notificator for incoming mail
Homepage: http://www.infodrom.org/projects/newmail/
Description-md5: 49b0168ce625e668ce3031036ad2f541
Tag: interface::commandline, mail::notification, role::program,
 scope::utility, works-with::mail
Section: mail
Priority: optional
Filename: pool/main/n/newmail/newmail_0.5-2_amd64.deb
Size: 14154
MD5sum: 5cd31aab55877339145517fb6d5646cb
SHA1: 869934a25a8bb3def0f17fef9221bed2d3a460f9
SHA256: 52ec3ac93cf8ba038fbcefe1e78f26ca1d59356cdc95e60f987c3f52b3f5e7ef

    """
    url = "%s/debian/dists/%s/main/binary-%s/Packages.gz" % (
        mirror_url,
        distro,
        arch
    )
    buf = urllib2.urlopen(url)
    f = gzip.GzipFile(fileobj=io.BytesIO(buf.read()))
    data = f.read()
    metadata = parse_package_metadata(data, mirror_url)
    with open(PACKAGES_FILE_NAME, 'w') as f:
        json.dump(metadata, f)

if __name__ == "__main__":
    main()
