load("//packages:deb_pkg.bzl", "deb_pkg")
load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_library")

deb_pkg(
    name = "ca-certs",
    pkg_name = "ca-certificates-java",
    source = "@debian_jessie//file",
)

go_binary(
    name = "deb_getter",
    library = ":go_default_library",
    visibility = ["//visibility:public"],
)

go_library(
    name = "go_default_library",
    srcs = ["main.go"],
    visibility = ["//visibility:private"],
    deps = ["//packages/parse:go_default_library"],
)

go_binary(
    name = "packages",
    library = ":go_default_library",
    visibility = ["//visibility:public"],
)
