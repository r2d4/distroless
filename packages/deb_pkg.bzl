def _impl(ctx):
  _get_package(ctx, ctx.file.source, ctx.attr.pkg_name, ctx.outputs.deb.path)

def _get_package(ctx, source_file, pkg_name, output_file):
  args = [
    "-source-file=" + source_file.path,
    "-pkg-name=" + pkg_name,
    "-output-file=" + output_file
  ]

  ctx.action(
    executable = ctx.executable.package_getter,
    arguments = args,
    outputs = [ctx.outputs.deb],
  )

  return struct(runfiles = ctx.runfiles(
    files = [source_file],
    collect_data=True
  ))

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
            cfg = "host",
            allow_single_file=True,
          ),
          "pkg_name": attr.string(),
      },
  outputs = {
    "deb": "%{pkg_name}.deb",
    #"metadata": "%{pkg_name}.metadata",
  },
)
