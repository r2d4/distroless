load("@subpar//:subpar.bzl", "par_binary")

load("//package_manager:dpkg.bzl", "test_rule")

par_binary(
    name = "dpkg_parser",
    srcs = ["dpkg_parser.py"],
    main = "dpkg_parser.py",
    visibility = ["//visibility:public"],
)
