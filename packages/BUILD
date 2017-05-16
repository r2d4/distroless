load("//packages:deb_pkg.bzl", "deb_pkg")
load("@io_bazel_rules_go//go:def.bzl", "go_binary")

deb_pkg(
    name = "ca-certs",
    pkg_name = "ca-certificates",
)

go_binary(
    name = "deb_getter",
    srcs = ["packages.go"],
    data = ["@debian_jessie//file"],
)



