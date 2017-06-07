def _dpkg_impl(repository_ctx):
  repository_ctx.file("BUILD", "")
#   repository_ctx.file("image/BUILD", """
# package(default_visibility = ["//visibility:public"])
# exports_files(["package_name.deb"])
# """)
  args = [
      "--packages-file" + repository_ctx.attr.packages_file.path,
      "--package-name" + repository_ctx.attr.package_name,
      "--mirror-url" + repository_ctx.attr.mirror_url,
      "--output-file" + repository_ctx.outputs.deb.path
  ]

#   repository_ctx.action(
#       executable = repository_ctx.executable._dpkg_parser,
#       inputs = [repository_ctx.file.packages_file],
#       arguments = args,
#       outputs = [repository_ctx.outputs.deb],
#   )

_dpkg = repository_rule(
    _dpkg_impl,
    attrs = {
        "packages_file": attr.label(allow_single_file = True),
        "package_name": attr.string(mandatory = True),
        "mirror_url": attr.string(mandatory = True),
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

  repository_ctx.download_and_extract(url, 
                                      output=repository_ctx.output.package_list, 
                                      type='tar.gz')

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