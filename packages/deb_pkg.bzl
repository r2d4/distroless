def _impl(ctx):
  args = [
    "-source-file=" + ctx.file.source.path,
    "-pkg-name=" + ctx.attr.pkg_name,
    "-output-file=" + ctx.outputs.deb.path
  ]

  ctx.action(
    executable = ctx.executable.package_getter,
    inputs = [ctx.file.source],
    arguments = args,
    outputs = [ctx.outputs.deb],
  )

deb_pkg = rule(
  implementation=_impl,
  attrs={
          "package_getter": attr.label(
                                default = Label("//packages:deb_getter"),
                                cfg = "host",
                                allow_files=True,
                                executable=True),
          #TODO(r2d4): should allow multiple sources
          "source": attr.label(
            default = Label("@debian_jessie//file"),
            cfg = "data",
            allow_single_file=True,
          ),
          "pkg_name": attr.string(),
      },
  outputs = {
    "deb": "%{pkg_name}.deb",
    #"metadata": "%{pkg_name}.metadata",
  },
)
