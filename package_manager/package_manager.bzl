load(":dpkg.bzl", "dpkg", "dpkg_src")

def package_manager_repositories():
  # TODO(r2d4): change bucket
  native.http_file(
      name = "dpkg_parser",
      url = ('https://storage.googleapis.com/r2d4minikube/dpkg_parser.par'),
      executable = True,
      sha256 = "5ad6ce4c3cb975c0f96e61809f1cf3e095b57c8ec3a395b8a1238fe1b13b95ba",
  )