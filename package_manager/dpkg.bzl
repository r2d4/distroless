def _dpkg_impl(repository_ctx):
  repository_ctx.file("file/BUILD", """
package(default_visibility = ["//visibility:public"])
deb_files = glob(["*.deb"])
exports_files(deb_files + ["packages.bzl"])
""")

  for pkg in repository_ctx.attr.packages:
    if pkg.find("+") > 0:
        old_pkg = pkg
        pkg = pkg.replace("+", "_")
        print("Package names that contain a + will be changed to _ for bazel compatibility.")
        print("%s will output %s//file:%s.deb" % (old_pkg, repository_ctx.name, pkg))

  package_files = ",".join([repository_ctx.path(src_path) for src_path in repository_ctx.attr.sources])

  args = [
      repository_ctx.path(repository_ctx.attr.dpkg_parser),
      "--package-files", package_files,
      "--packages", ",".join(repository_ctx.attr.packages),
      "--bazel-compatible-names=True",
  ]

  result = repository_ctx.execute(args)
  if result.return_code:
    fail("dpkg_parser command failed: %s (%s)" % (result.stderr, " ".join(args)))

_dpkg = repository_rule(
    _dpkg_impl,
    attrs = {
        "sources": attr.label_list(
            allow_files = True,
        ),
        "packages": attr.string_list(),
        "dpkg_parser": attr.label(
            executable = True,
            default = Label("@dpkg_parser//file:dpkg_parser.par"),
            cfg = "host",
        ),
    },
)

def _dpkg_src_impl(repository_ctx):
  repository_ctx.file("file/BUILD", """
package(default_visibility = ["//visibility:public"])
exports_files(["Packages.json"])
""")
  args = [
      repository_ctx.path(repository_ctx.attr._dpkg_parser),
      "--download-and-extract-only=True",
      "--mirror-url=" + repository_ctx.attr.url,
      "--arch=" + repository_ctx.attr.arch, 
      "--distro=" + repository_ctx.attr.distro
  ]
  result = repository_ctx.execute(args)
  if result.return_code:
    fail("dpkg_parser command failed: %s (%s)" % (result.stderr, " ".join(args)))

_dpkg_src = repository_rule(
    _dpkg_src_impl,
    attrs = {
        "url": attr.string(),
        "arch": attr.string(),
        "distro": attr.string(),
        "_dpkg_parser": attr.label(
            executable = True,
            default = Label("@dpkg_parser//file:dpkg_parser.par"),
            cfg = "host",
        ),
    },
)

def dpkg(**kwargs):
  _dpkg(**kwargs)

def dpkg_src(**kwargs):
  _dpkg_src(**kwargs)
