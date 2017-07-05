package(default_visibility = ["//visibility:public"])

load("@io_bazel_rules_docker//docker:docker.bzl", "docker_build")

# An intermediate image for Java and other "mostly statically" compiled languages
docker_build(
    name = "cc",
    base = "//base:base",
    debs = [
        "@package_bundle//file:libgcc1.deb",
        "@package_bundle//file:libstdc__6.deb",
    ],
)
