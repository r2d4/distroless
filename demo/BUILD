load("//demo:empty.bzl", "execute")
load("@io_bazel_rules_go//go:def.bzl", "go_binary")

execute(
    name = "e",
    contents = "write this",
    out = "test.txt",
)

go_binary(
    name="hello_go",
    srcs=["main.go"],
)