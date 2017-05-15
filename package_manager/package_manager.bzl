load(":dpkg.bzl", "dpkg", "dpkg_src")

def package_manager_repositories():
  native.http_file(
      name = "dpkg_parser",
      url = ('https://storage.googleapis.com/r2d4minikube/dpkg_parser'),
  )