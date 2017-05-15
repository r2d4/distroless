def _deb_src_impl(ctx):
  base_url = "%s/debian/dists/%s/main/binary-%s" % (
    ctx.attr.mirror_url,
    ctx.attr.distro,
    ctx.attr.arch
  )

  url = "%s/Packages.gz" % base_url

  args = [
    "-url=" + url,
    "-output-file=" + ctx.outputs.package_list.path,
  ]

  ctx.action(
    executable = ctx.executable.source_getter,
    arguments = args,
    outputs = [ctx.outputs.package_list],
  )

  return struct(
    base_url = ctx.attr.mirror_url
  )

deb_src = rule(
    attrs = {
        "source_getter": attr.label(
            default = Label("//packages/deb_src_getter:deb_src_getter"),
            cfg = "host",
            allow_files = True,
            executable = True,
        ),
        "mirror_url": attr.string(),
        "distro": attr.string(),
        "arch": attr.string(),
    },
    outputs = {
        "package_list": "Packages.gz",
    },
    implementation = _deb_src_impl,
)
