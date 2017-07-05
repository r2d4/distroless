load(":dpkg.bzl", "dpkg", "dpkg_src")

def package_manager_repositories():
  native.http_file(
      name = "dpkg_parser",
      url = ('https://storage.googleapis.com/distroless/package_manager_tools/v0.2/dpkg_parser.par'),
      executable = True,
      sha256 = "bb701c03d4f3f97a562cc6f72adbafb36dc4a6f202f9058d212eba4ef8016870",
  )
