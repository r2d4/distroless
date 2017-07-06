load(":dpkg.bzl", "dpkg", "dpkg_src")

def package_manager_repositories():
  native.http_file(
      name = "dpkg_parser",
      url = ('https://storage.googleapis.com/r2d4bucket/v0.4/dpkg_parser.par'),
      executable = True,
      sha256 = "e01abafc7f4da4f04d37b1980da39587b4ac75f0d6fb2d41abfbb2d408a75b69",
  )
