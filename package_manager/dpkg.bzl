def _dpkg_impl(repository_ctx):
  repository_ctx.file("WORKSPACE", "workspace(name = \"%s\")\n" % repository_ctx.name)
  repository_ctx.file("BUILD", "")
  repository_ctx.file("src/BUILD", """
package(default_visibility = ["//visibility:public"])
exports_files(["pkg.deb"])
""")

  args = [
      "dpkg_parser " + 
      "--packages-file" + repository_ctx.attr.source.path,
      "--package-name" + repository_ctx.name,
      "--mirror-url" + repository_ctx.attr.source.mirror_url,
      "--output-file" + repository_ctx.outputs.deb.path
  ]

  result = repository_ctx.execute(args)
  print("hello!")
  if result.return_code:
    fail("Getting dpkg_parser command failed: %s (%s)" % (result.stderr, " ".join(args)))

_dpkg = repository_rule(
    _dpkg_impl,
    attrs = {
        "source": attr.label(allow_single_file = True),
        "_dpkg_parser": attr.label(
            executable = True,
            default = Label("@dpkg_parser//file:dpkg_parser.par"),
            cfg = "host",
        ),
    },
)

def _dpkg_src_impl(repository_ctx):
  url = "%s/debian/dists/%s/main/binary-%s/Packages.gz" % (
    repository_ctx.attr.mirror_url,
    repository_ctx.attr.distro,
    repository_ctx.attr.arch
  )
  repository_ctx.file("BUILD", "")
  repository_ctx.file("src/BUILD", """
package(default_visibility = ["//visibility:public"])
exports_files(["Packages.gz"])
""")
  repository_ctx.download(url, output='src/Packages.gz')

_dpkg_src = repository_rule(
    _dpkg_src_impl,
    attrs = {
        "mirror_url": attr.string(),
        "distro": attr.string(),
        "arch": attr.string(),
    },
)

def dpkg(**kwargs):
  _dpkg(**kwargs)

def dpkg_src(**kwargs):
  _dpkg_src(**kwargs)


def test_rule_impl(ctx):
  print(ctx.files)

test_rule = rule(
    test_rule_impl,
    attrs = { 
        "test": attr.label(allow_files = True) 
    },
)