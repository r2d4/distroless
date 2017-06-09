load(":dpkg.bzl", "dpkg", "dpkg_src")

def package_manager_repositories():
  # TODO(r2d4): change bucket
  native.http_file(
      name = "dpkg_parser",
      url = ('https://storage.googleapis.com/r2d4minikube/dpkg_parser.par'),
      executable = True,
      sha256 = "12f7c08b31f6270c2380a052980f381c4ca8742dad25b4009bae9abf920e4018",
  )