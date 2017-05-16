load("//packages:deb_pkg.bzl", "deb_pkg")
load("@io_bazel_rules_go//go:def.bzl", "go_binary")

deb_pkg(
    name = "ca-certs",
    pkg_name = "ca-certificates",
    source = "@debian_jessie//file"
)

go_binary(
    name = "deb_getter",
    srcs = ["packages.go"],
)



