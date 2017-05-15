load("//packages:deb_pkg.bzl", "deb_pkg")
load("//packages:deb_src.bzl", "deb_src")

deb_pkg(
    name = "ca-certs",
    pkg_name = "ca-certificates-java",
    source = ":debian_jessie",
)

deb_src(
    name = "debian_jessie",
    arch = "amd64",
    distro = "jessie",
    mirror_url = "http://httpredir.debian.org",
)
